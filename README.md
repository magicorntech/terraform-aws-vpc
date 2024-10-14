# terraform-aws-vpc

Magicorn made Terraform Module for AWS Provider
--
```
module "vpc" {
  source      = "magicorntech/vpc/aws"
  version     = "0.1.0"
  tenant      = var.tenant
  name        = var.name
  environment = var.environment

  # VPC Configuration
  cidr_block    = "10.1.0.0/16"
  vpc_fl_cw_log = false (if true cloudwatch logging is enabled)
  vpc_fl_s3_exp = false (if true s3 logging is enabled)
  nat_gateway   = false
  nat_count     = 2

  # If != nat_gateway
  nat_instance  = "c6gn.large"
  nat_ami       = "ami-059f069ff80edb269" # use AL2023 latest image

  # Subnet Mapping
  pbl_sub_count = [
    {cidr="10.1.8.0/21", zone="b", eip=""}, # 1
    {cidr="10.1.16.0/21", zone="c", eip=""} # 1
  ]
  pvt_sub_count = [
    {cidr="10.1.40.0/21", zone="b"},
    {cidr="10.1.48.0/21", zone="c"}
  ]
  eks_sub_count = [
    {cidr="10.1.72.0/21", zone="b"},
    {cidr="10.1.80.0/21", zone="c"}
  ]
  db_sub_count  = []
}
```

## Notes
1) eip attribute should stay empty if you plan to create new NAT IPs. If you intend to use your existing IP set, you can type-in the Elastic IP allocation id like "eipalloc-053aa42329c5a2784" in each respective subnet map.