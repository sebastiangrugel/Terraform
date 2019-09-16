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

variable "template_linux_centos" {
  type = "string"
  
}

variable "virtual_machines_dns_servers" {
  type = "list"
  default = []
  }

variable "vm_mgt_ip" {
  type = "string"
  }

variable "vm_gw" {
  type = "string"
  
  }

variable "vm_dns" {
  type = "list"
  default = []
}

variable "hostname" {
  type = "string"
  }

variable "host_domain" {
  type = "string"
}


