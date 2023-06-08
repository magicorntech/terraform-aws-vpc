data "aws_region" "current" {}

locals {
  nat_count = (
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == true) ? 1 : false ||
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == false) ? length(var.pbl_sub_count) : false ||
    (length(var.pbl_sub_count) == 0) ? 0 : 0
  )
}