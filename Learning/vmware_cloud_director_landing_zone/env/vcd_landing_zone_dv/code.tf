module "vcd_landing_zone_1" {
    source = "../../modules/general/"

# DLA ORGANIZCJI
    env_org_name = "Datavision_Demo" #nazwa organizacji
# DLA VDC
    env_vdc_name = "Env_Datavision_Demo"
    env_vdc_storage_profile_name = "SSD Storage Policy"
    env_vdc_edge = "Env_Datavision_Demo_EDGE_GATEWAY_01" #nazwa edga
}

