resource "vcd_org_vdc" "vdc-silverCpu-silverHdd" {
  name        = "vdc-silverCpu-silverHdd"
  description = "PROVIDER_SILVER_CLOUD VDC with Silver Storage Profile"
  #org         = "terra-Sebastian-Grugel"
  org         = "${vcd_org.terra-org.name}"
  

  allocation_model = "AllocationVApp"
  network_pool_name = "EXEA_01_NETWORK_POOL_VXLAN_02"
  provider_vdc_name = "EXEA_01_PROVIDER_SILVER_CLOUD_01"
  cpu_speed = 2600

  compute_capacity {
    cpu {
      limit = 2600
    }

    memory {
      limit = 2048
    }
  }

  storage_profile {
    name     = "SILVER Storage Policy"
    limit    = 35000
    default  = true    
  }

  network_quota = 2

  enabled                  = true
  enable_thin_provisioning = true
  enable_fast_provisioning = true
  delete_force             = true
  delete_recursive         = true

  depends_on = ["vcd_org.terra-org"]
}
