provider "vcd" {
  user                 = "${var.vcd_user}"
  password             = "${var.vcd_pass}"
  org                  = "${var.vcd_org}"
  vdc                  = "${var.vcd_vdc}"
  url                  = "${var.vcd_url}"
  allow_unverified_ssl = "${var.vcd_allow_unverified_ssl}"
  max_retry_timeout    = "60"
}