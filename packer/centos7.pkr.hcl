variable "vsphere_password" {}

variable "env" {
  default = "prd"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vsphere-iso" "centos7" {
  CPUs                 = 2
  RAM                  = 2048
  RAM_reserve_all      = true
  boot_command         = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
  cluster              = "Compute"
  convert_to_template  = true
  datacenter           = "Lab"
  datastore            = "vStorage1"
  guest_os_type        = "centos7_64Guest"
  http_directory       = "http"
  insecure_connection  = "true"
  iso_checksum         = "659691c28a0e672558b003d223f83938f254b39875ee7559d1a4a14c79173193"
  iso_urls             = ["http://mirror.mobap.edu/centos/7.8.2003/isos/x86_64/CentOS-7-x86_64-Minimal-2003.iso"]
  network_adapters {
    network      = "Management Network"
    network_card = "vmxnet3"
  }
  notes        = "Built via Packer"
  password     = "${var.vsphere_password}"
  ssh_password = "password"
  ssh_username = "root"
  storage {
    disk_controller_index = 0
    disk_size             = 30000
    disk_thin_provisioned = true
  }
  username       = "administrator@vsphere.local"
  vcenter_server = "vc.lab.local"
  vm_name        = "build-centos7-${var.env}"
}

# a build block invokes sources and runs provisionning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.vsphere-iso.centos8"]

  provisioner "shell" {
    inline = ["ls /"]
  }
}
