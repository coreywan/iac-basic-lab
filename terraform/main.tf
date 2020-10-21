variable "vsphere_password" {}

variable "infoblox_password" {}

variable "env" {
  default = "prd"
}

provider "infoblox"{
  username  = "admin"
  password  = var.infoblox_password
  server    = "infoblox.iac.lab.local"
}

provider "vsphere" {
    user                    = "administrator@vsphere.local"
    password                = var.vsphere_password
    vsphere_server          = "vc.lab.local"
    allow_unverified_ssl    = true
}

data "vsphere_datacenter" "dc" {
  name = "Lab"
}

data "vsphere_datastore" "datastore" {
  name          = "vStorage1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Compute"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = "Management Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "build-centos7-${var.env}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "gitlab" {
  name             = "${var.env}-gitlab"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.env}-gitlab"
        domain    = "iac.lab.local"
      }

      // network_interface {
      //   ipv4_address = "192.168.2.111"
      //   ipv4_netmask = 24
      // }
      dns_server_list = ["192.168.2.102"]
      ipv4_gateway = "192.168.2.1"
    }
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "yum install -y curl policycoreutils-python openssh-server postfix",
  #    "systemctl enable sshd && systemctl start sshd",
  #    "systemctl enable postfix && systemctl start postfix",
  #    "curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | bash",
  #    "EXTERNAL_URL="https://prd-gitlab.lab.local" yum install -y gitlab-ee"
  #  ]
  #  connection {
  #    type      = "ssh"
  #    host      = self.default_ip_address
  #    user      = "root"
  #    password  = "password"
  #  }
  #}

  // provisioner "ansible-local" {
  //   playbook_file   = "../ansible/local-provision-gitlab.yml"
  //   extra_arguments = ["--extra-vars", "\"env=${var.env}\""]
  // }
}

resource "infoblox_ip_allocation" "gitlab"{
  vm_name     = "${var.env}-gitlab"
  cidr        = "192.168.2.0/24"
  mac_addr    = vsphere_virtual_machine.gitlab.network_interface.0.mac_address
  ip_addr     = vsphere_virtual_machine.gitlab.default_ip_address
  vm_id       = vsphere_virtual_machine.gitlab.id
  tenant_id   = "${var.env}-gitlab"
  zone        = "iac.lab.local"
  enable_dns  = true
}

// resource "infoblox_ip_association" "gitlab"{
//   vm_name     = "${var.env}-gitlab"
//   cidr        = "192.168.2.0/24"
//   mac_addr    = vsphere_virtual_machine.gitlab.network_interface.0.mac_address
//   ip_addr     = vsphere_virtual_machine.gitlab.default_ip_address
//   vm_id       = vsphere_virtual_machine.gitlab.id
//   tenant_id   = "${var.env}-gitlab"
//   zone        = "iac.lab.local"
// }
