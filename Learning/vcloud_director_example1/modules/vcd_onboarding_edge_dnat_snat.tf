
// ###### Konfiguracja EDGa ==> DNATy
resource "vcd_dnat" "web" {

  edge_gateway    = "${var.org_edge_gateway}"
  external_ip     = "${var.edge1_ex_ip}"
  port            = 80
  internal_ip     = "192.168.1.10"
  translated_port = 8080
}



resource "vcd_snat" "outbound" {
  edge_gateway = "${var.org_edge_gateway}"
  external_ip  = "${var.edge1_ex_ip}"
  internal_ip  = "${var.org_edge_default_network_routed}"
}