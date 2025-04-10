provider "aws" {
  region = var.aws_region
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  master_username         = var.master_username
  master_password         = var.master_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "docdb_sg" {
  name        = "${var.cluster_identifier}-security-group"
  description = "Security group for DocumentDB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_identifier}-security-group"
  }
}

output "docdb_endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "docdb_port" {
  value = aws_docdb_cluster.docdb.port
}

output "docdb_username" {
  value = var.master_username
  sensitive = true
}

output "docdb_password" {
  value = var.master_password
  sensitive = true
}
