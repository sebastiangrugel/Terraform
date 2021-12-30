# Provider do generowania znaków losowych używanych dla maszyn wirtualnych
resource "random_id" "random_vdc_id" {
  byte_length = 2
}

resource "vcd_vapp" "web" {
  name = "web"

  metadata = {
    boss = "Why is this vApp empty?"
    john = "I don't really know. Maybe somebody did forget to clean it up."
  }
}