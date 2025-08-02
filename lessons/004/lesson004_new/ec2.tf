# EC2 instance for the local web app
resource "aws_instance" "web" {
  ami                         = "ami-02003f9f0fde924ea" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type, eu-central-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet1.id # Place this instance in one of the private subnets
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = false # Assigns a public IP address to your instance. You should disable it to avoid getting a second public IP
  user_data_replace_on_change = true  # Replace the user data when it changes

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOT
    #!/bin/bash
    set -ex

    # Update package lists
    apt-get update -y

    # Install Docker
    curl -sSL https://get.docker.com/ | sh

    systemctl start docker
    systemctl enable docker

    usermod -aG docker ubuntu

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf awscliv2.zip aws
    EOT

  tags = {
    Name = "Django_EC2_Complete_Server"
  }
}

# Allocate an Elastic IP (EIP)
resource "aws_eip" "django_eip" {
  domain = "vpc" # ✅ Replaces deprecated 'vpc = true'
  tags = {
    Name = "Django_EC2_EIP"
  }
}

# Associate the EIP with your EC2 instance
resource "aws_eip_association" "django_eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.django_eip.id
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
