terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version= "3.4.0"
    }
  }
}

provider "vcd" {
  //version  = "~> 2.4"
  url      = var.vcd_url
  org      = var.vcd_org
  vdc      = var.vcd_vdc
  user     = var.vcd_user
  password = var.vcd_pass
  max_retry_timeout    = "60"
  allow_unverified_ssl = "true"
}