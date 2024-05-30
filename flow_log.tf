#Create flow log with CloudWatch Log Group as target
resource "aws_flow_log" "main_cloudwatch" {
  count                    = var.vpc_fl_cw_log == true ? 1 : 0
  vpc_id                   = aws_vpc.main.id
  iam_role_arn             = aws_iam_role.main_cloudwatch[0].arn
  log_destination          = aws_cloudwatch_log_group.main[0].arn
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  log_format               = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${traffic-path} $${type} $${version} $${vpc-id}"

  tags = {
    Name        = "${var.tenant}-${var.name}-${aws_vpc.main.id}-flow-logs-cw-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

# Create Cloudwatch Log Group to collect VPC flow logs
resource "aws_cloudwatch_log_group" "main" {
  count             = var.vpc_fl_cw_log == true ? 1 : 0
  name              = "${var.tenant}-${var.name}-${aws_vpc.main.id}-fl-group-${var.environment}"
  retention_in_days = 7

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${aws_vpc.main.id}-fl-group-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"

  }
}

# IAM Roles for Creating Flow Logs
resource "aws_iam_role" "main_cloudwatch" {
  count = var.vpc_fl_cw_log == true || var.vpc_fl_s3_exp == true ? 1 : 0 
  name  = "${var.tenant}-${var.name}-vpc-fl-${aws_vpc.main.id}-cw-role-${var.environment}"

  tags = {
    Name        = "${var.tenant}-${var.name}-vpc-fl-${aws_vpc.main.id}-cw-role-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main_cloudwatch" {
  count  = var.vpc_fl_cw_log == true || var.vpc_fl_s3_exp == true ? 1 : 0
  name   = "${var.tenant}-${var.name}-vpc-fl-${aws_vpc.main.id}-cw-policy-${var.environment}"
  role   = aws_iam_role.main_cloudwatch[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# Create S3 Bucker to collect Flow Logs in a S3 Bucket
resource "aws_s3_bucket" "main" {
  count         = var.vpc_fl_s3_exp == true ? 1 : 0
  bucket        = "${var.tenant}-${var.name}-vpc-fl-${random_id.s3[0].hex}-${var.environment}"
  force_destroy = false

  tags = {
    Name        = "${var.tenant}-${var.name}-vpc-fl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}

# Create flow log with s3 as target
resource "aws_flow_log" "main_s3" {
  count                    = var.vpc_fl_s3_exp == true ? 1 : 0
  vpc_id                   = aws_vpc.main.id
  log_destination          = aws_s3_bucket.main[0].arn
  log_destination_type     = "s3"
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  log_format               = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${traffic-path} $${type} $${version} $${vpc-id}"

  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${aws_vpc.main.id}-flow-logs-s3-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}
