module "dev_environment" {
    source = "../../modules"
    hosts = ["sg-esxi01.exea.dev","sg-esxi02.exea.dev"]
    environment = "DEV"
    network_interfaces = ["vmnic1"]
}
