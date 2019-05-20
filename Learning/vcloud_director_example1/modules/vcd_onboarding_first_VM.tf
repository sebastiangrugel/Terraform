resource "vcd_network_routed" "net-terr1" {
  name         = "Terr-Network-FirstVM"
  edge_gateway = "${var.org_edge_gateway}"
  gateway      = "10.10.0.1"
  netmask = "255.255.255.0"

  static_ip_pool {
    start_address = "10.10.0.2"
    end_address   = "10.10.0.254"
  }
}



//Tworzenie vAPPa
resource "vcd_vapp" "firstvm" {
name = "web"
depends_on = ["vcd_network_routed.net-terr1"]
}

// Tworzenie maszyny z katalogu
  resource "vcd_vapp_vm" "firstvm" {
  vapp_name     = "${vcd_vapp.firstvm.name}"
  name          = "CentosFirstVM-${count.index + 1}"
  catalog_name  = "Linux"
  template_name = "TEMP-CentOS-6.7"
  count = "3"
  power_on = "false"

network {
    type               = "org"
    name               = "Env_Sebastian_NETWORK_01"
    ip_allocation_mode = "POOL"
  }

  depends_on = ["vcd_vapp.firstvm"]
}

resource "vcd_dnat" "firstvm" {

  edge_gateway    = "${var.org_edge_gateway}"
  external_ip     = "${var.edge1_ex_ip}"
  port            = 43389
  internal_ip     = "10.0.0.10"
  translated_port = 3389
  
  depends_on = ["vcd_vapp_vm.firstvm"]
}

resource "vcd_firewall_rules" "firstvm" {
  edge_gateway   = "${var.org_edge_gateway}"
  default_action = "drop"

  rule {
    description      = "Terraform-FirstVM-allow-RDP"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "3389"
    //destination_port = ["${var.owarteporty}"]
    destination_ip   = "${var.destination-ip}"
    source_port      = "any"
    source_ip        = "185.15.45.94"
    
  }
depends_on = ["vcd_vapp_vm.firstvm"]
}

