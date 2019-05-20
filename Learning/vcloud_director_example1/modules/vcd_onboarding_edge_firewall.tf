// ###### Konfiguracja EDGa ==> Firewall

resource "vcd_firewall_rules" "fw2" {
  edge_gateway   = "${var.org_edge_gateway}"
  default_action = "drop"

  rule {
    description      = "Terraform-drop_FTP"
    policy           = "drop"
    protocol         = "tcp"
    destination_port = "21"
    //destination_port = ["${var.owarteporty}"]
    destination_ip   = "${var.destination-ip}"
    source_port      = "any"
    source_ip        = "${var.source-ip}"
  }
}

