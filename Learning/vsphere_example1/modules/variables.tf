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

