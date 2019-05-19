module "exea_environment" {
    source = "../../modules"
    company = "NOKIA2019"
    liczbakatalogow = "3"
    //otwarteporty = ["25","3389","22","80"]
    // Otwarcie ruchu sieciowego (firewall)
    source-ip = "180.16.16.200"
    destination-ip = "10.10.10.0/24"
    org_edge_gateway = "Env_Sebastian_EDGE_GATEWAY_01"
}