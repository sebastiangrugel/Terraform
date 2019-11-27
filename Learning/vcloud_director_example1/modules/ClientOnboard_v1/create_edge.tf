resource "vcd_edgegateway" "edge-compact" {
    org = "${vcd_org.terra-org.name}"
    vdc = "vdc-silverCpu-silverHdd"

    name                    = "edge-compact"
  description             = "Edge Gateway Compact"
  configuration           = "compact"
  default_gateway_network = "EXEA_01_EXTERNAL_NETWORK_01"
  external_networks       = ["EXEA_01_EXTERNAL_NETWORK_01"]
  advanced                = true

  depends_on = [
    "vcd_org_vdc.vdc-silverCpu-silverHdd"
  ]
}

