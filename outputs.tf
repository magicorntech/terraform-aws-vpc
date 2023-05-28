output "vpc_id" {
	value = aws_vpc.main.id
}

output "cidr_block" {
	value = aws_vpc.main.cidr_block
}

output "pbl_subnet_ids" {
	value = aws_subnet.main_pbl.*.id
}

output "pvt_subnet_ids" {
	value = aws_subnet.main_pvt.*.id
}

output "eks_subnet_ids" {
	value = aws_subnet.main_eks.*.id
}

output "db_subnet_ids" {
	value = aws_subnet.main_db.*.id
}