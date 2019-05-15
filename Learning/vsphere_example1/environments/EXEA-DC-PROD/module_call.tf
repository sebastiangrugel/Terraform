module "dev_environment" {
    source = "../../modules"
    hosts = ["sg-esxi02.exea.dev","sg-esxi03.exea.dev"]
    environment = "PROD"
}
