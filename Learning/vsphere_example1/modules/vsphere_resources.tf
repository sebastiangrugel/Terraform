// Pobranie informacji o istniejących hostach
data "vsphere_host" "hosts" {
  count         = "${length(var.hosts)}"
  name          = "${var.hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
  }

// Pobranie informacji o istniejącym datacenter
data "vsphere_datacenter" "old_datacenter" {
  name = "${var.company}-DC-${var.environment}"
  }

// Tworzenie jednego datasotra z 3 znalezionych dysków dla pierwszego ESXi
data "vsphere_vmfs_disks" "available1" {
  host_system_id = "${data.vsphere_host.hosts.0.id}"
  rescan         = true
  filter         = "naa.60"
}

resource "vsphere_vmfs_datastore" "datastore1" {
  name           = "Datastore-${data.vsphere_host.hosts.0.name}-${var.environment}-Local"
  host_system_id = "${data.vsphere_host.hosts.0.id}"
  disks = ["${data.vsphere_vmfs_disks.available1.disks}"]
  depends_on = ["vsphere_compute_cluster.compute_cluster"]
}

// Tworzenie jednego datasotra z 3 znalezionych dysków dla drugiego ESXi
data "vsphere_vmfs_disks" "available2" {
  host_system_id = "${data.vsphere_host.hosts.1.id}"
  rescan         = true
  filter         = "naa.60"
}

resource "vsphere_vmfs_datastore" "datastore2" {
  name           = "Datastore-${data.vsphere_host.hosts.1.name}-${var.environment}-Local"
  host_system_id = "${data.vsphere_host.hosts.1.id}"
  disks = ["${data.vsphere_vmfs_disks.available2.disks}"]
  depends_on = ["vsphere_compute_cluster.compute_cluster"]
}



// Tworzenie wspołdzielonego datastora NFSv3
resource "vsphere_nas_datastore" "nfsdatastore" {
  name            = "Datastore-${var.environment}-NFS"
  host_system_ids = ["${data.vsphere_host.hosts.*.id}"]
  type         = "NFS"
  remote_hosts = ["${var.nfs_server_ip}"]
     remote_path  = "/mnt/nfs/nfs1"
  depends_on = ["vsphere_compute_cluster.compute_cluster"]
}


// Tworzenie klastra hostów
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "Terraform${var.company}_Cluster-VMUG_${var.environment}"
  datacenter_id   = "${data.vsphere_datacenter.old_datacenter.id}"
  host_system_ids = ["${data.vsphere_host.hosts.*.id}"]
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled = false
  force_evacuate_on_destroy = true
}

// Tworzenie DVS
resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "VDS-${var.company}-${var.environment}-MGMT"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
  uplinks         = ["uplink1"]
  
  host {
   
   host_system_id = "${data.vsphere_host.hosts.0.id}"
  devices        = ["${var.network_interfaces}"]
  }

  host {
    host_system_id = "${data.vsphere_host.hosts.1.id}"
    devices        = ["${var.network_interfaces}"]
  }
  depends_on = ["vsphere_compute_cluster.compute_cluster"]
}

resource "vsphere_distributed_virtual_switch" "dvs_nsx" {
  name          = "VDS-${var.company}-${var.environment}-NSX"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
  depends_on = ["vsphere_compute_cluster.compute_cluster"]
}




// Tworzenie portgrup na VDS

 resource "vsphere_distributed_port_group" "pg_mgmt" {
  name = "PG-${var.company}-${var.environment}-MGT"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 0
  }
 resource "vsphere_distributed_port_group" "pg_backup" {
  name = "PG-${var.company}-${var.environment}-BACKUP"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1002
    
}
resource "vsphere_distributed_port_group" "pg_repl" {
  name = "PG-${var.company}-${var.environment}-REPLICATION"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1003
}
resource "vsphere_distributed_port_group" "pg_vmotion" {
  name = "PG-${var.company}-${var.environment}-vMOTION"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1004
}
resource "vsphere_distributed_port_group" "pg_vsan" {
  name = "PG-${var.company}-${var.environment}-VSAN"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1005
}




// ##################### KONFIGURACJA RESOURCE POOL #####################################

//Tworzymy ResourcePool // Creating Resource Pool
resource "vsphere_resource_pool" "resource_pool_priority" {
  name = "Mission Critical VMs - ${var.environment}"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}
resource "vsphere_resource_pool" "resource_pool_regular" {
  name = "Regular VMs - ${var.environment}"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}
resource "vsphere_resource_pool" "resource_pool_mgmt" {
  name = "Management - ${var.environment}"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}


// ############################## KONFIGURACJA FOLDERÓW #################################

//Tworzenie folderów pod kategorie maszyn
resource "vsphere_folder" "mgmt" {
  type = "vm"
  path = "Management"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}
//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "ActiveDirectory" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/ActiveDirectory"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}
//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "Monitoring" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/Monitoring"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}

//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "backup" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/Backup MGMT"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}


//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "automation" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/Automation"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}


//Tworzenie folderu dedykowane dla zespołów
resource "vsphere_folder" "teams" {
  type = "vm"
  path = "Teams"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}
//Automatyczne generowanie subfolderów dla pierwszych 5 zespołów
resource "vsphere_folder" "teamfolder" {
  type = "vm"
  path = "${vsphere_folder.teams.path}/Team-${count.index + 1}"
datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
count = 5
}

// ############################# TWORZENIE PUSTYCH MASZYN WIRTUALNYCH ###############################


resource "vsphere_virtual_machine" "vm" {
  name             = "VM-${var.company}-${var.environment}-${count.index + 1}"
  # resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}" # lokalizacja w klastrze poza resource pool
  resource_pool_id = "${vsphere_resource_pool.resource_pool_mgmt.id}"
  datastore_id     = "${vsphere_nas_datastore.nfsdatastore.id}"

  num_cpus = 2
  memory   = 256
  guest_id = "other3xLinux64Guest"
  count = 2
  
  wait_for_guest_ip_timeout = 0
  wait_for_guest_net_timeout = 0
  
  network_interface {
    network_id = "${vsphere_distributed_port_group.pg_mgmt.id}"
  }

  disk {
    label = "disk0"
    size  = 5
  }
  depends_on = ["vsphere_nas_datastore.nfsdatastore"]
}

// ############################# TWORZENIE MASZYN WIRTUALNYCH Z TEMPLATE ###############################

// Zczytanie informacji na temat istniejącego 
data "vsphere_virtual_machine" "template_linux_1" {
name = "${var.template_linux_centos}"
datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}

resource "vsphere_virtual_machine" "vm_template" {
count = 1
name             = "VM-template_${var.company}-${var.environment}-${count.index + 1}"
resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
datastore_id     = "${vsphere_nas_datastore.nfsdatastore.id}"

num_cpus = 2
memory   = 1024
guest_id = "${data.vsphere_virtual_machine.template_linux_1.guest_id}"

network_interface {
    network_id   = "${vsphere_distributed_port_group.pg_mgmt.id}"
    //adapter_type = "${data.vsphere_virtual_machine.template_linux_1.network_interface_types[0]}"
    adapter_type = "vmxnet3"
  }

disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.template_linux_1.disks.0.size}"
  }
# Additional disk
  disk {
    label = "disk1"
    size  = "5"
    unit_number = 1
  }

clone {
    template_uuid = "${data.vsphere_virtual_machine.template_linux_1.id}"


customize {
      linux_options {
        host_name = "${var.hostname}"
        domain    = "${var.host_domain}"
             }

         network_interface {
        ipv4_address = "${var.vm_mgt_ip}"
        ipv4_netmask = 24
      }     
      ipv4_gateway = "${var.vm_gw}"
      dns_server_list = ["${var.vm_dns}"]
      
    }
}
wait_for_guest_ip_timeout = 0
wait_for_guest_net_timeout = 0
}