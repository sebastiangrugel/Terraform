// Tworzenie własnego katalohu na swoje obrazy
resource "vcd_catalog" "myNewCatalog" {

  name             = "${var.company}-Catalog-${count.index + 1}"
  description      = "catalog for files"
  delete_recursive = "true"
  delete_force     = "true"
  count = "${var.liczbakatalogow}"
}


// Konfiguracja Firewalla
resource "vcd_firewall_rules" "fw2" {
  edge_gateway   = "${var.org_edge_gateway}"
  default_action = "drop"

  rule {
    description      = "allow-"
    policy           = "drop"
    protocol         = "tcp"
    destination_port = "21"
    //destination_port = "${var.owarteporty}"
    destination_ip   = "${var.destination-ip}"
    source_port      = "any"
    source_ip        = "${var.source-ip}"
  }
}
