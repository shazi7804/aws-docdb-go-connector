provider "aws" {
  region = var.aws_region
}


## DocumentDB
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

## Web services
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "docdb-go-instance-connect"

  instance_type          = "t3.micro"
  key_name               = "scottliao"
  vpc_security_group_ids = [aws_security_group.docdb_ec2_sg.id]
  subnet_id              = var.subnet_ids[0]

  tags = {
    Name   = "docdb-go-instance-connect"
  }

  user_data = <<-EOL
    #!/bin/bash
    yum install -y git golang
    git clone https://github.com/shazi7804/aws-docdb-go-connector
    cd app/ && go build -o main .
  EOL
}

resource "aws_security_group" "docdb_ec2_sg" {
  name        = "docdb-ec2-sg"
  description = "Docdb instance connect"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "docdb_user_setup" {
  depends_on = [aws_docdb_cluster.docdb]

  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -i 'localhost,' \
      -e docdb_endpoint="${aws_docdb_cluster.docdb.endpoint}" \
      -e docdb_admin_user="${var.master_username}" \
      -e docdb_admin_password="${var.master_password}" \
      docdb-user.yml
    EOT
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
