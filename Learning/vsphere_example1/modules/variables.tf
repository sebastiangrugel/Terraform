//variable "datacenter_name" { 
//description = "Datacenter name to create"
//type = "string"
  
//}

variable "hosts" {
  default = []
  type = "list"
}

variable "environment" {
    type = "string"
  
}

variable "network_interfaces" {
  default = []
  type = "list"
}

variable "company" {
  type = "string"
}
