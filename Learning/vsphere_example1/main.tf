// Blok odpowiedzialny za łączenie z vCenter
provider "vsphere" {
  user                 = "${var.vc_user}"
  password             = "${var.vc_pass}"
  vsphere_server = "${var.vc_vsphere_server}"
  allow_unverified_ssl = "${var.vc_allow_unverified_ssl}"
  }

// Tworzenie datacenter dla VMUG // Creating datacenter for VMUG
resource "vsphere_datacenter" "vmug_datacenter" {
  name       = "TerraformDC-VMUG"
}



// Tworzenie Clastra // Host Cluster creation
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "terraform-compute-cluster-test"
  datacenter_id   = "${vsphere_datacenter.vmug_datacenter.moid}"
  depends_on = ["vsphere_datacenter.vmug_datacenter"]
}