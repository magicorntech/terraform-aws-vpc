# terraform-aws-vpc

Magicorn made Terraform Module for AWS Provider
--
```
module "vpc" {
  source      = "../../../modules/vpc"
  tenant      = var.tenant
  name        = var.name
  environment = var.environment

  # VPC Configuration
  cidr_block    = "10.1.0.0/16"
  single_az_nat = true
  pbl_sub_count = [
    {cidr="10.1.0.0/21", zone="a"},
    {cidr="10.1.8.0/21", zone="b"},
    {cidr="10.1.16.0/21", zone="c"}
  ]
  pvt_sub_count = [
    {cidr="10.1.32.0/21", zone="a"},
    {cidr="10.1.40.0/21", zone="b"},
    {cidr="10.1.48.0/21", zone="c"}
  ]
}
```