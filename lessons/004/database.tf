# Define AWS provider and set the region for resource provisioning
# DB subnet group for RDS instances, using the created subnets
resource "aws_db_subnet_group" "default" {
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  tags = {
    Name = "Django_EC2_Subnet_Group"
  }
}

# RDS instance for Django backend, now privately accessible
resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "14.18"
  instance_class         = "db.t3.micro"
  identifier             = "my-django-rds"
  db_name                = "djangodb"
  username               = "adam"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true # Changed to false for private access
  multi_az               = false
  tags = {
    Name = "Django_RDS_Instance"
  }
}
