// Pobranie informacji o istniejących hostach
data "vsphere_host" "hosts" {
  count         = "${length(var.hosts)}"
  name          = "${var.hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
  }

// Pobranie informacji o istniejącym klastrze
data "vsphere_datacenter" "old_datacenter" {
  name = "EXEA-DC-${var.environment}"
  }



// Tworzenie jednego datasotra z 3 znalezionych dysków dla pierwszego ESXi
data "vsphere_vmfs_disks" "available1" {
  host_system_id = "${data.vsphere_host.hosts.0.id}"
  rescan         = true
  filter         = "naa.60"
}

resource "vsphere_vmfs_datastore" "datastore1" {
  name           = "Datastore-${data.vsphere_host.hosts.0.name}_${var.environment}_Local"
  host_system_id = "${data.vsphere_host.hosts.0.id}"
  //folder         = "datastore-folder"
  disks = ["${data.vsphere_vmfs_disks.available1.disks}"]
}

// Tworzenie jednego datasotra z 3 znalezionych dysków dla drugiego ESXi
data "vsphere_vmfs_disks" "available2" {
  host_system_id = "${data.vsphere_host.hosts.1.id}"
  rescan         = true
  filter         = "naa.60"
}

resource "vsphere_vmfs_datastore" "datastore2" {
  name           = "Datastore-${data.vsphere_host.hosts.1.name}_${var.environment}_Local"
  host_system_id = "${data.vsphere_host.hosts.1.id}"
  //folder         = "datastore-folder"
  disks = ["${data.vsphere_vmfs_disks.available2.disks}"]
}




resource "vsphere_nas_datastore" "nfsdatastore" {
  name            = "terraform-testnfs"
  host_system_ids = ["${data.vsphere_host.hosts.*.id}"]
  type         = "NFS"
  remote_hosts = ["10.3.5.62"]
  remote_path  = "/mnt/nfs/nfs1"
}





//To działa na jednego hosta i konkretny dysk
/*resource "vsphere_vmfs_datastore" "datastore" {
  name           = "terraform-test"
    host_system_id = "${data.vsphere_host.hosts.0.id}"
  disks = [
    "naa.6000c29c55aaa3b7b04b086b666a2535",
      ]
}

*/




// Tworzenie klastra hostów
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "Terraform${var.company}_Cluster-VMUG_${var.environment}"
   datacenter_id   = "${data.vsphere_datacenter.old_datacenter.id}"
  host_system_ids = ["${data.vsphere_host.hosts.*.id}"]
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled = true
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
}

resource "vsphere_distributed_virtual_switch" "dvs_nsx" {
  name          = "VDS-${var.company}-${var.environment}-NSX"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}




// Tworzenie portgrup na VDS

 resource "vsphere_distributed_port_group" "pg_mgmt" {
  name = "PG-${var.company}-${var.environment}-MGT"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1001
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


