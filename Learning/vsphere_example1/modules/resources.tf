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
  name          = "VDS-${var.company}-MGMT"
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
  name          = "VDS-${var.company}-NSX"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}





// Tworzenie portgrup na VDS

 resource "vsphere_distributed_port_group" "pg_mgmt" {
  name = "PG-${var.company}-MGT"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1001
  }
 resource "vsphere_distributed_port_group" "pg_backup" {
  name = "PG-${var.company}-BACKUP"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1002
    
}
resource "vsphere_distributed_port_group" "pg_repl" {
  name = "PG-${var.company}-REPLICATION"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1003
}
resource "vsphere_distributed_port_group" "pg_vmotion" {
  name = "PG-${var.company}-VMOTION"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1004
}
resource "vsphere_distributed_port_group" "pg_vsan" {
  name = "PG-${var.company}-VSAN"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id = 1005
}




// ##################### KONFIGURACJA RESOURCE POOL #####################################

//Tworzymy ResourcePool // Creating Resource Pool
resource "vsphere_resource_pool" "resource_pool_priority" {
  name = "Mission Critical VMs"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}
resource "vsphere_resource_pool" "resource_pool_regular" {
  name = "Regular VMs"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}
resource "vsphere_resource_pool" "resource_pool_mgmt" {
  name = "Management"
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
