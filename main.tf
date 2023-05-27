##### Create VPC
resource "aws_vpc" "main" {
  cidr_block                        = var.cidr_block
  enable_dns_support                = true
  enable_dns_hostnames              = true
  assign_generated_ipv6_cidr_block  = false

  tags = {
    Name        = "${var.tenant}-${var.name}-vpc-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}

##### Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id        = aws_vpc.main.id

  tags = {
    Name        = "${var.tenant}-${var.name}-igw-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Terraform   = "yes"
  }
}