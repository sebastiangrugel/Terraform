module "dev_environment" {
    source = "../../modules"
    hosts = ["sg-esxi03.exea.dev","sg-esxi04.exea.dev"]
    environment = "PROD"
    network_interfaces = ["vmnic1"]
    company = "EXEA"
}