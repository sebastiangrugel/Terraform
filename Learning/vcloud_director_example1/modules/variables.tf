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

