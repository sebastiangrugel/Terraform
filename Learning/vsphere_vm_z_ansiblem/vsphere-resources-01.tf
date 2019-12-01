// ############################# TWORZENIE MASZYN WIRTUALNYCH Z TEMPLATE ###############################

// Zczytanie informacji na temat istniejącego 
data "vsphere_virtual_machine" "template_linux_1" {
#name = "${var.template_linux_centos}"
name = "centos7.7-template"
datacenter_id = "${data.vsphere_datacenter.primary-datacenter.id}"
}


resource "vsphere_virtual_machine" "vm_template" {
count = 1
name             = "Ansible_node_${count.index + 1}"
#resource_pool_id = "${vsphere_compute_cluster.compute_cluster_t.resource_pool_id}" - klaster terraformowy
resource_pool_id = "${data.vsphere_compute_cluster.compute_cluster.resource_pool_id}"
datastore_id     = "${data.vsphere_datastore.datastore-large1.id}"

num_cpus = 2
memory   = 1024
guest_id = "${data.vsphere_virtual_machine.template_linux_1.guest_id}"

network_interface {
    network_id   = "${data.vsphere_network.siec.id}"
    //adapter_type = "${data.vsphere_virtual_machine.template_linux_1.network_interface_types[0]}"
    adapter_type = "vmxnet3"
  }

disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.template_linux_1.disks.0.size}"
  }
# Additional disk
  disk {
    label = "disk1"
    size  = "5"
    unit_number = 1
  }

clone {
    template_uuid = "${data.vsphere_virtual_machine.template_linux_1.id}"


customize {
      linux_options {
        host_name = "centoshostname"
        #host_name = "${var.hostname}"
        domain    = "mojadomena.local"


             }

         network_interface {
        ipv4_address = "192.168.5.51"
        #ipv4_address = "192.168.5.1${count.index + 1}" #jakby co to odkomentuj działa jeślie nie masz DHCP
        #ipv4_address = "${var.vm_mgt_ip}" #zwykły string
        ipv4_netmask = 24 #jakby co to odkomentuj działa jeślie nie masz DHCP
      }     
      ipv4_gateway = "192.168.5.1" #jakby co to odkomentuj działa jeślie nie masz DHCP
      #ipv4_gateway = "${var.vm_gw}"
      dns_server_list = ["168.168.5.3","8.8.8.8"]
      #dns_server_list = ["${var.vm_dns}"]
      

      
    }
}

provisioner "remote-exec" {
    inline = [
          "hostname && date >> test.txt",
          "sudo yum -y update",
          "sudo yum install -y python-setuptools",
          "sudo easy_install pip",
          "sudo pip install pyvmomi",
          "sudo pip install ansible",
          "hostname && date >> test.txt",
    ]
  }
  connection {
      type        = "ssh"
      host        = "192.168.5.51"
      user        = "root"
# Hasło swiadomie widoczne. Tylko do tego projektu wewnętrznie.
      password    = "Aido123!"
    }

wait_for_guest_ip_timeout = 0
wait_for_guest_net_timeout = 0
# depends_on = ["vsphere_datacenter.moje_datacenter"]
}
