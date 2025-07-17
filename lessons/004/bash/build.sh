echo "Updating system and installing essentials..."
sudo apt update && sudo apt install -y python3.12 python3.12-venv python3.12-dev python3-pip docker.io git tree

# === CHECK PYTHON INSTALLATION ===
if ! python3.12 --version; then
    echo "Python 3.12 not found"
    exit 1
fi

# === exports, key, acc ===
export SECRET_KEY=pass1234
export DB_NAME=djangodb
export DB_USER_NM=adam
export DB_USER_PW=pass1234
export DB_IP=my-django-rds.youruri.eu-central-1.rds.amazonaws.com  # add your own uri
export DB_PORT=5432
export TF_VAR_secret_key=pass1234
export TF_VAR_db_password=pass1234
export AWS_ACCESS_KEY_ID="yourownkey" # add your own key
export AWS_SECRET_ACCESS_KEY="yourownkey" # add your own key
export AWS_REGION="eu-central-1"

# === SETUP VIRTUAL ENVIRONMENT ===
echo "Creating and activating virtual environment..."
django-admin startproject django_ec2_complete
# 1. Rename the folder
mv django_ec2_complete be_deleted
# 2. Copy all contents from 'be_deleted' to the current directory
cp -r be_deleted/* .
# 3. Delete the 'be_deleted' folder and its contents
rm -rf be_deleted

python3.12 -m venv venv
source venv/bin/activate

# === INSTALL PYTHON DEPENDENCIES ===
pip install --upgrade pip
pip install django gunicorn psycopg2-binary
pip freeze > requirements.txt
python manage.py migrate

# Comment out or remove this line if you want to continue script after this,
# because it blocks here until stopped

# python manage.py runserver # uncomment if you want to check

echo "✅ Setup complete. Visit your local Django project: http://127.0.0.1:8000/ and http://127.0.0.1:8000/admin"
sleep 10

# === BUILD DOCKERFILE ===
echo "Building Dockerfile..."
cat > Dockerfile <<EOF
FROM python:3.12.2-slim-bullseye

ENV PYTHONBUFFERED=1
ENV PORT=8080

WORKDIR /app
COPY . /app/

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE \$PORT

CMD ["gunicorn", "django_ec2_complete.wsgi:application", "--bind", "0.0.0.0:8080"]
EOF

# === BUILD DOCKER IMAGE ===
docker build -t django-ec2-complete:latest .

# === RUN DOCKER CONTAINER ===
echo "Running Docker container on http://localhost:8000 ..."
docker run -d -p 8000:8080 django-ec2-complete:latest

# === SHOW TREE STRUCTURE ===
tree -L 1

echo "✅ Setup complete. Visit your local on Docker Django project: http://localhost:8000"

sleep 10

set -e

# Variables
AWS_REGION="eu-central-1"
AWS_ACCOUNT_ID="yourownACCOUNT_ID" # add your own ACCOUNT_ID
REPO_NAME="django-ec2-complete"
IMAGE_NAME="django-ec2-complete:latest"
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

echo "Creating ECR repository..."
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION || echo "Repository may already exist."

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Tagging Docker image..."
docker tag $IMAGE_NAME $ECR_URI

echo "Pushing Docker image to ECR..."
docker push $ECR_URI

echo "Done! Image pushed to $ECR_URI"

sleep 10

# Move into the project directory
#cd django_ec2_complete || { echo "Directory 'django_ec2_complete' not found!"; exit 1; }

# Create the database.tf Terraform configuration
cat > database.tf <<'EOF'
# Define AWS provider and set the region for resource provisioning
# DB subnet group for RDS instances, using the created subnets
resource "aws_db_subnet_group" "default" {
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  tags = {
    Name = "Django_EC2_Subnet_Group"
  }
}

# Security group for RDS, allows PostgreSQL traffic
resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.default.id
  name        = "DjangoRDSSecurityGroup"
  description = "Allow PostgreSQL traffic"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Updated to "10.0.0.0/16"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Updated to "10.0.0.0/16"
  }
  tags = {
    Name = "RDS_Security_Group"
  }
}

variable "db_password" {
  description = "The password for the database" 
  type        = string
  sensitive   = true
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
EOF

echo "database.tf has been created in the current directory."

sleep 3



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
    description      = "Allow port 8000"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress {
    description = "Allow ports 22-80"
    from_port   = 22
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  ami                         = "ami-02003f9f0fde924ea" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type, eu-central-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet1.id # Place this instance in one of the private subnets
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
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
    docker pull 89#####48.dkr.ecr.eu-central-1.amazonaws.com/django-ec2-complete:latest # add your own uri

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



# VPC Outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.default.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.default.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.default.id
}

# EC2 Output
output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "ec2_ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = aws_instance.web.ami
}

# ECR Output (manually coded as you're referencing an existing repo)
output "ecr_repository_url" {
  description = "URL of the ECR Docker repository"
  value       = "897729123748.dkr.ecr.eu-central-1.amazonaws.com/django-ec2-complete"
}


# AWS SSH
variable "key_name" {
  default = "mykey"
}

resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.tls_private_key.public_key_openssh
}

resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("~/.ssh/${var.key_name}.pem")
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.tls_private_key.private_key_pem
}
EOF

echo "main.tf has been created in the current directory."
sleep 5

set -e  # exit immediately if any command fails

echo "🔷 Running terraform init..."
terraform init

echo "🔷 Running terraform plan..."
terraform plan

# === INSTALL PYTHON DEPENDENCIES ===
export TF_VAR_secret_key=pass1234
export TF_VAR_db_password=pass1234

echo "✅ Done. Check config and run - terraform apply. Connect with SSH"