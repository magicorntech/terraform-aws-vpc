data "aws_region" "current" {}

resource "random_id" "s3" {
  count         = var.vpc_fl_s3_exp == true ? 1 : 0
  byte_length = 4
}