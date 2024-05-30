data "aws_region" "current" {}

resource "random_id" "s3" {
  count         = var.vpc_fl_s3_exp == true ? 1 : 0
  byte_length = 4
}

locals {
  nat_count = (
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == true) ? 1 : false ||
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == false) ? length(var.pbl_sub_count) : false ||
    (length(var.pbl_sub_count) == 0) ? 0 : 0
  )
}