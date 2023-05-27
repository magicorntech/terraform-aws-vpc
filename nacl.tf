##### Create Public Access Control List
resource "aws_network_acl" "main_pbl" {
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_pbl.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pbl-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}

##### Create Private Access Control List
resource "aws_network_acl" "main_pvt" {
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_pvt.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pvt-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}