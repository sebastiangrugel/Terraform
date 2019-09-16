// Tworzenie własnego katalohu na swoje obrazy
resource "vcd_catalog" "myNewCatalog" {

  name             = "${var.company}-Catalog-${count.index + 1}"
  description      = "catalog for files"
  delete_recursive = "true"
  delete_force     = "true"
  count = "${var.liczbakatalogow}"
}




