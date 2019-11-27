#resource "vcd_org" "terra-vcd-org" {
resource "vcd_org" "terra-org" {
  name             = "terra-Sebastian-Grugel"
  full_name        = "Terraform Sebastian Grugel Full name Organization"
  description      = "Terraform description"
  is_enabled       = "true"
  delete_recursive = "false" // uwaga: true usuwa katalog Linux podczas usuwania organizacji
  delete_force     = "true"
}