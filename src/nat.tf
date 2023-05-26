##### Create NAT Gateway
resource "aws_eip" "nat_gateway" {
  count      = (var.single_az_nat == true) ? 1 : length(var.pbl_sub_count)
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
    Terraform   = "yes"
  }
}

resource "aws_nat_gateway" "main" {
  count         = (var.single_az_nat == true) ? 1 : length(var.pbl_sub_count)
  allocation_id = element(aws_eip.nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.main_pbl.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.tenant}-${var.name}-natgw-pbl-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}