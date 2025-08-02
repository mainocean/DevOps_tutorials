#!/bin/bash

# Move into the project directory
cd django_ec2_complete || { echo "Directory 'django_ec2_complete' not found!"; exit 1; }

# Create the main.tf Terraform configuration
cat > main.tf <<'EOF'
# Define AWS provider and set the region for resource provisioning
provider "aws" {
  region = "eu-central-1"
}

# Create a Virtual Private Cloud to isolate the infrastructure
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Django_EC2_VPC"
  }
}

# Internet Gateway to allow internet access to the VPC
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Django_EC2_Internet_Gateway"
  }
}

# Route table for controlling traffic leaving the VPC
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "Django_EC2_Route_Table"
  }
}

# Subnet within VPC for resource allocation, in availability zone eu-central-1a
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"
  tags = {
    Name = "Django_EC2_Subnet_1"
  }
}

# Another subnet for redundancy, in availability zone eu-central-1b
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1b"
  tags = {
    Name = "Django_EC2_Subnet_2"
  }
}

# Associate subnets with route table for internet access
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.default.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.default.id
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Only allow HTTPS traffic from everywhere
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

# Define variable for RDS password to avoid hardcoding secrets
variable "secret_key" {
  description = "The Secret Key for Django"
  type        = string
  sensitive   = true
}

# EC2 instance for the local web app
resource "aws_instance" "web" {
  ami                    = "ami-0c101f26f147fa7fd" # Amazon Linux
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet1.id # Place this instance in one of the private subnets
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  associate_public_ip_address = true # Assigns a public IP address to your instance
  user_data_replace_on_change = true # Replace the user data when it changes

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOT
    #!/bin/bash
    set -ex

    # Update package lists
    apt-get update -y

    # Install prerequisites
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Start Docker service
    systemctl start docker
    systemctl enable docker

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf awscliv2.zip aws


    # Authenticate to ECR
    docker login -u AWS -p "$(aws ecr get-login-password --region eu-central-1)" 897729123748.dkr.ecr.eu-central-1.amazonaws.com/django-ec2-complete

    # Pull the Docker image from ECR
    docker pull 897729123748.dkr.ecr.eu-central-1.amazonaws.com/django-ec2-complete:latest

    # Run the Docker image with environment variables
    docker run -d -p 80:8080 \
    --env SECRET_KEY="${var.secret_key}" \
    --env DB_NAME=djangodb \
    --env DB_USER_NM=adam \
    --env DB_USER_PW="${var.db_password}" \
    --env DB_IP="${aws_db_instance.default.address}" \
    --env DB_PORT=5432 \
    897729123748.dkr.ecr.eu-central-1.amazonaws.com/django-ec2-complete:latest
  EOT

  tags = {
    Name = "Django_EC2_Complete_Server"
  }
}

# IAM role for EC2 instance to access ECR
resource "aws_iam_role" "ec2_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com",
      },
      Effect = "Allow",
    }],
  })
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the role
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "django_ec2_complete_profile"
  role = aws_iam_role.ec2_role.name
}
EOF

echo "main.tf has been created in the current directory."
