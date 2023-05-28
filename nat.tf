##### Create NAT IPs
resource "aws_eip" "nat_gateway" {
  count      = (lookup(var.pbl_sub_count[0], "eip") == "") ? local.nat_count : 0
  vpc        = true
  depends_on = [aws_internet_gateway.main]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-natgw-eip-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Use existing NAT IPs
data "aws_eip" "nat_gateway" {
  count = (lookup(var.pbl_sub_count[0], "eip") == "") ? 0 : local.nat_count
  id    = lookup(var.pbl_sub_count[count.index], "eip")
}

##### Create NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = local.nat_count
  allocation_id = (lookup(var.pbl_sub_count[0], "eip") == "") ? element(aws_eip.nat_gateway.*.id, count.index) : element(data.aws_eip.nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.main_pbl.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.tenant}-${var.name}-natgw-pbl-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}