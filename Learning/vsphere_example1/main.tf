// Blok odpowiedzialny za łączenie z vCenter
provider "vsphere" {
  user                 = "${var.vc_user}"
  password             = "${var.vc_pass}"
  vsphere_server       = "${var.vc_vsphere_server}"
  allow_unverified_ssl = "${var.vc_allow_unverified_ssl}"
}

//Deklarujemy informacje o hostach w vCenter czesc 1

variable "hosts" {
  default = [
    "sg-esxi01.exea.dev",
    "sg-esxi02.exea.dev",
    "sg-esxi03.exea.dev",
  ]
}

/*
//Zaciągamy informacje o hostach w vCenter czesc 2
data "vsphere_host" "hosts" {
  count         = "${length(var.hosts)}"
  name          = "${var.hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
  depends_on = ["vsphere_datacenter.vmug_datacenter"]
}
*/

// Tworzenie datacenter dla VMUG // Creating datacenter for VMUG
resource "vsphere_datacenter" "vmug_datacenter" {
  name = "TerraformDC-VMUG-EXEA"
}

data "vsphere_datacenter" "old_datacenter" {
  name = "ExistingDC"
}

data "vsphere_host" "host1" {
  name          = "sg-esxi01.exea.dev"
  datacenter_id = "${data.vsphere_datacenter.old_datacenter.id}"
}

/*

// Tworzenie Clastra // Host Cluster creation
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "TerraformCluster-VMUG"
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id   = "${vsphere_datacenter.vmug_datacenter.moid}"
  //host_system_ids = ["${data.vsphere_host.hosts.*.id}"]
  host_system_ids = ["${data.vsphere_host.host1.id}"]
  depends_on = ["vsphere_datacenter.vmug_datacenter"]
}

*/


/*


//Tworzymy ResourcePool // Creating Resource Pool
resource "vsphere_resource_pool" "resource_pool_test" {
  name = "Test"
  parent_resource_pool_id = "${vsphere_compute_cluster.compute_cluster.resource_pool_id}"
    depends_on = ["vsphere_compute_cluster.compute_cluster"]
}
resource "vsphere_resource_pool" "resource_pool_dev" {
  name = "Development"
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
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
}
//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "ActiveDirectory" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/ActiveDirectory"
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
}
//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "Monitoring" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/Monitoring"
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
}
//Tworzenie subfolderów pod kategorie maszyn
resource "vsphere_folder" "automation" {
  type = "vm"
  path = "${vsphere_folder.mgmt.path}/Automation"
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
}


//Tworzenie folderu dedykowane dla zespołów
resource "vsphere_folder" "teams" {
  type = "vm"
  path = "Teams"
  // użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
  datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
}
//Automatyczne generowanie subfolderów dla pierwszych 5 zespołów
resource "vsphere_folder" "teamfolder" {
  type = "vm"
  path = "${vsphere_folder.teams.path}/Team-${count.index + 1}"
// użyłem poniżej moid zamiast id bo inaczej wyrzucał bład 
datacenter_id = "${vsphere_datacenter.vmug_datacenter.moid}"
count = 5
}


*/

