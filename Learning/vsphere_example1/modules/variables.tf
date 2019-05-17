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

variable "nfs_server_ip" {
  type = "list"
  default = []
  }