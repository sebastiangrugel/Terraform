variable "vcd_user" { description = "vCloud user" }
variable "vcd_pass" { description = "vCloud pass" }
variable "vcd_url" { description = "vCloud url" }
variable "vcd_allow_unverified_ssl" { description = "vCloud SSL" }
variable "vcd_max_retry_timeout" { description = "vCloud Timeout" }

variable "vcd_org" { 
    description = "vCloud org" 
       }
    
variable "vcd_vdc" { 
    description = "vCloud VDC" 
    //default = "test_seba_VXLAN"
}