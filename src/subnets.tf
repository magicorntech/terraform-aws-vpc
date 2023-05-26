##### Create Public Subnets
resource "aws_subnet" "main_pbl" {
  count                   = length(var.pbl_sub_count)
  cidr_block              = lookup(var.pbl_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.pbl_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-pbl-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}

##### Create Private Subnets
resource "aws_subnet" "main_pvt" {
  count                   = length(var.pvt_sub_count)
  cidr_block              = lookup(var.pvt_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.pbl_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-pvt-${lookup(var.pvt_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}