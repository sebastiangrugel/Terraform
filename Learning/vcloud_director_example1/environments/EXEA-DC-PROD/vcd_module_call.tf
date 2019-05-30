module "exea_environment" {
    source = "../../modules"
    company = "NOKIA2019"
    liczbakatalogow = "3"
    // Parametry dla EDGE ==> Otwarcie ruchu sieciowego (firewall)
    source-ip = "180.16.16.200"
    destination-ip = "10.10.10.0/24"
    // Parametry dla EDGE ==> Ogólne
    edge1_ex_ip = "185.15.47.5"
    org_edge_gateway = "Env_Sebastian_EDGE_GATEWAY_01"
    // Parametry dla EDGE ==> np. do SNAT, DNAT
    org_edge_default_network_routed = "10.0.0.0/24"
}