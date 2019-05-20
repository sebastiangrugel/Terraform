variable "company" {
  type = "string"
}
variable "liczbakatalogow" {
  type = "string"
}

variable "owarteporty" {
  default = []
  type = "list"
}

variable "source-ip" {
  type = "string"
}

variable "destination-ip" {
  type = "string"
}

variable "org_edge_gateway" {
  type = "string"
}

variable "edge1_ex_ip" {
  type = "string"
 }

variable "org_edge_default_network_routed" {
  type = "string"
}
