variable "vsphere_password" {}
variable "env" {
  default = "prd"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vsphere-iso" "centos8" {
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
  iso_checksum         = "47ab14778c823acae2ee6d365d76a9aed3f95bb8d0add23a06536b58bb5293c0"
  iso_urls             = ["http://mirror.mobap.edu/centos/8.2.2004/isos/x86_64/CentOS-8.2.2004-x86_64-minimal.iso"]
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
  vm_name        = "build-centos8-${var.env}"
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
