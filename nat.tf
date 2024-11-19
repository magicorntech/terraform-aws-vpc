##### Create NAT IPs
resource "aws_eip" "nat" {
  count      = (var.nat_gateway == true && lookup(var.pbl_sub_count[0], "eip") == "") ? var.nat_count : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-nat-eip-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

##### Use existing NAT IPs
data "aws_eip" "nat" {
  count = (lookup(var.pbl_sub_count[0], "eip") == "") ? 0 : var.nat_count
  id    = lookup(var.pbl_sub_count[count.index], "eip")
}

##### Create NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = (var.nat_gateway == true) ? var.nat_count : 0
  allocation_id = (lookup(var.pbl_sub_count[0], "eip") == "") ? element(aws_eip.nat.*.id, count.index) : element(data.aws_eip.nat.*.id, count.index)
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

##### Create NAT Instance
module "ec2-nat" {
  count       = (var.nat_gateway == true) ? 0 : var.nat_count
  source      = "magicorntech/ec2-instance/aws"
  version     = "0.0.6"
  tenant      = var.tenant
  name        = var.name
  environment = var.environment
  vpc_id      = aws_vpc.main.id
  cidr_block  = aws_vpc.main.cidr_block
  subnet_id   = element(aws_subnet.main_pbl.*.id, count.index)

  ##### EC2 Configuration
  ec2_name                    = "nat-instance-${lookup(var.pbl_sub_count[count.index], "zone")}"
  ami_id                      = var.nat_ami
  instance_type               = var.nat_instance
  associate_public_ip_address = true
  create_eip                  = true # you must have an internet gateway attached | otherwise, boom!
  detailed_monitoring         = false
  stop_protection             = true
  termination_protection      = true
  source_dest_check           = false
  key_name                    = null # can be null
  user_data                   = <<EOF
#!/bin/bash
sudo yum update
sudo yum upgrade -y
sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
sudo touch /etc/sysctl.d/custom-ip-forwarding.conf
sudo echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/custom-ip-forwarding.conf
sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
NIC_NAME=$(netstat -i | awk 'NR==3 {print $1}')
sudo /sbin/iptables -t nat -A POSTROUTING -o $NIC_NAME -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save
EOF

  ##### EBS Configuration
  encryption                    = false
  kms_key_id                    = null
  delete_volumes_on_termination = true

  # Root Volume Configuration
  root_volume_type = "gp3" # can be null
  root_volume_size = 10    # can be null
  root_throughput  = null  # can be null
  root_iops        = null  # can be null

  # Additional Volume Configuration (only one)
  ebs_device_name = "sda2"
  ebs_volume_type = "gp2" # can be null
  ebs_volume_size = 0     # if 0 - no additional disk created
  ebs_throughput  = null  # can be null
  ebs_iops        = null  # can be null

  # Security Group Configuration
  ingress = [
    {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = aws_vpc.main.cidr_block
    }
  ]
}
