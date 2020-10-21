# IAC Example

NOTE: Still under construction

Purpose: Leverage with WWT IAC Labs to help customers understand the different constructs of IaC.

## Scratchpad Instructions

1. Clone this repository:

```sh
cd
git clone https://github.com/coreywan/iac-basic-lab.git
cd ~/iac-basic-lab
```

2. Build the Centos Image

```sh
cd ~/iac-basic-lab/packer
export PKR_VAR_vsphere_password='{{ PASSWORD }}' && packer build -force centos8.pkr.hcl
```


3. Deploy Gitlab Server

```sh
cd ~/iac-basic-lab/terraform
terraform init
export TF_VAR_vsphere_password='{{ PASSWORD }}'
terraform plan
terraform apply -auto-approve