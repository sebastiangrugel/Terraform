module "dev_environment" {
    source = "../../modules"
    hosts = ["sg-esxi01.exea.dev"]
    environment = "DEV"
}
