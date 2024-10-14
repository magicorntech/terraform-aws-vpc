##### Adopt Private Route Table (Default/Main)
resource "aws_default_route_table" "main_default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name        = "${var.tenant}-${var.name}-default-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Create Public Route Table
resource "aws_route_table" "main_pbl" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pbl-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Create Private Route Table
resource "aws_route_table" "main_pvt" {
  count  = (length(var.pvt_sub_count) > 0) ? var.nat_count : 0
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = (var.nat_gateway == true) ? [true] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
    }
  }

  dynamic "route" {
    for_each = (var.nat_gateway != true) ? [true] : []

    content {
      cidr_block           = "0.0.0.0/0"
      network_interface_id = element(module.ec2-nat.*.primary_nic, count.index)
    }
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pvt-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Create EKS Route Table
resource "aws_route_table" "main_eks" {
  count  = (length(var.eks_sub_count) > 0) ? var.nat_count : 0
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = (var.nat_gateway == true) ? [true] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
    }
  }

  dynamic "route" {
    for_each = (var.nat_gateway != true) ? [true] : []

    content {
      cidr_block           = "0.0.0.0/0"
      network_interface_id = element(module.ec2-nat.*.primary_nic, count.index)
    }
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-eks-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Create DB Route Table
resource "aws_route_table" "main_db" {
  count  = (length(var.db_sub_count) > 0) ? 1 : 0
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-db-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Route Table Association for Public Subnets
resource "aws_route_table_association" "main_pbl_route_association" {
  count          = length(var.pbl_sub_count)
  subnet_id      = element(aws_subnet.main_pbl.*.id, count.index)
  route_table_id = aws_route_table.main_pbl.id
}

##### Route Table Association for Private Subnets
resource "aws_route_table_association" "main_pvt_route_association" {
  count          = length(var.pvt_sub_count)
  subnet_id      = element(aws_subnet.main_pvt.*.id, count.index)
  route_table_id = element(aws_route_table.main_pvt.*.id, count.index)
}

##### Route Table Association for EKS Subnets
resource "aws_route_table_association" "main_eks_route_association" {
  count          = length(var.eks_sub_count)
  subnet_id      = element(aws_subnet.main_eks.*.id, count.index)
  route_table_id = element(aws_route_table.main_eks.*.id, count.index)
}

##### Route Table Association for DB Subnets
resource "aws_route_table_association" "main_db_route_association" {
  count          = length(var.db_sub_count)
  subnet_id      = element(aws_subnet.main_db.*.id, count.index)
  route_table_id = aws_route_table.main_db[0].id
}
