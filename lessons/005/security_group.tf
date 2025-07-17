# locals settings

locals {
  ingress_ports = {
    "SSH"          = 22
    "HTTP"         = 80
    "HTTPS (cert)" = 443
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "EC2_Security_Group"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.ingress_ports
    content {
      description = ingress.key
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2_Security_Group"
  }
}

#===== rds ======

# Security group for RDS, allows PostgreSQL traffic
resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.default.id
  name        = "DjangoRDSSecurityGroup"
  description = "Allow PostgreSQL traffic"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Only allow internal VPC access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] # Internal access only
  }
  tags = {
    Name = "RDS_Security_Group"
  }
}
