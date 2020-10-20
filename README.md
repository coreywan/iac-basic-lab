# IAC Example

NOTE: Still under construction

Purpose: Leverage with WWT IAC Labs to help customers understand the different constructs of IaC.

## Scratchpad Instructions

1. Clone this repository:

```sh
cd
git clone https://github.com/coreywan/iac-basic-lab.git
cd iac-basic-lab
```

2. Build the Centos Image

```sh
cd packer
export PKR_VAR_vsphere_password='{{ PASSWORD }}' && packer build -force centos8.pkr.hcl
```
