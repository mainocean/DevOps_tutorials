<p align="center">
  <img src="https://github.com/user-attachments/assets/d27dec6e-fb2a-4046-9e2f-c66fec75a7a4" alt="Project Screenshot" width="1100"/>
</p>


# 🚀 All-in-One Django Deployment to AWSFull production setup using Docker, EC2, RDS, Route 53, and Terraform.

This project demonstrates how to deploy a Django web application in production on AWS with:

✅ A Dockerized Django app on EC2

✅ A PostgreSQL database hosted on Amazon RDS

✅ Infrastructure managed with Terraform

✅ HTTPS secured with AWS ACM and a custom domain via Route 53

📖 Tutorial reference:
```
https://blog.lamorre.co/django-production/django-ec2-complete
```

### 🛠️ Tech Stack

- 🐍 **Django 4+** (Python 3.12)  
- 🐘 **PostgreSQL 16** (Amazon RDS)  
- 🐳 **Docker** & **Gunicorn**  
- ☁️ **AWS** (EC2, RDS, VPC, IAM, ACM, Route 53)  
- 🧱 **Terraform** (for IaC)


### 📦 Project Structure

```
django_ec2_complete/                  # Root of the project

├── .github/                          # GitHub workflows/config (CI/CD)
├── .terraform/                       # Terraform working directory (auto-created, not usually in repo)
├── aws/                              # (likely) AWS-specific configs/scripts

├── bash/                             # Bash scripts for automation
│   ├── build.sh                      # Build the project/container
│   ├── create_main_tf.sh             # Script to generate Terraform main config
│   ├── database.sh                   # Database-related automation
│   ├── push_to_ecr.sh                # Push Docker image to AWS ECR
│   └── start_pj.sh                   # Script to start the Django project

├── django_ec2_complete/              # Django project source code
│   ├── __pycache__/                  # Python bytecode cache (auto-generated)
│   ├── __init__.py                   # Marks this as a Python package
│   ├── asgi.py                       # ASGI config for async servers
│   ├── settings.py                   # Django settings (DB, installed apps, etc.)
│   ├── urls.py                       # URL routes
│   └── wsgi.py                       # WSGI config for production servers

├── docs/                             # (likely) project documentation

├── venv/                             # Python virtual environment
│   ├── bin/                          # Executables and scripts
│   ├── lib/                          # Installed Python packages
│   ├── lib64/                        # Symlink or additional libs
│   └── pyvenv.cfg                    # Virtualenv config

├── .gitignore                        # Files/folders to ignore in git
├── .terraform.lock.hcl               # Terraform provider lock file
├── db.sqlite3                        # Django SQLite database

# Infrastructure as Code (Terraform):
├── database.tf                       # Terraform DB resources
├── domain.tf                         # Terraform Route53 domain config
├── ec2.tf                            # Terraform EC2 instance config
├── network.tf                        # Terraform VPC, subnets, routing, etc.
├── outputs.tf                        # Terraform outputs
├── providers.tf                      # Terraform provider settings
├── security_group.tf                 # Terraform security groups
├── ssh.tf                            # Terraform SSH keypair, etc.
├── terraform.tfstate                 # Terraform state file (tracks infra state)
├── terraform.tfstate.backup          # Backup of state file
├── variable.tf                       # Terraform input variables

├── Dockerfile                        # Build Docker image for Django app
├── manage.py                         # Django CLI management tool
├── README.md                         # Project description & usage
├── requirements.txt                  # Python dependencies

```
### 🚀 Step-by-Step Deployment
### 1️⃣ Start a Django Project

bash                                             Copy
```
python3.12 -m pip install django
django-admin startproject django_ec2_complete
cd django_ec2_complete
```

### Set up a virtual environment, install dependencies, and run:
Now that we have a Django project, let’s install a virtual environment and the necessary dependencies.

```
python3.12 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install django gunicorn psycopg2-binary
pip freeze > requirements.txt
```
- django is needed for Django
- gunicorn is needed to run Django in production
- psycopg2-binary connects Django to PostgreSQL
Our Django project is up and we have the correct dependencies installed. Now let’s run Django.
bash
Copy
```
python manage.py runserver
```
### 2️⃣ Dockerize the App

Create a Dockerfile:

```
FROM python:3.12.2
ENV PYTHONBUFFERED=1 PORT=8080
WORKDIR /app
COPY . /app/
RUN pip install --upgrade pip && pip install -r requirements.txt
CMD gunicorn django_ec2_complete.wsgi:application --bind 0.0.0.0:$PORT
EXPOSE $PORT
```
### Then build and run:

bash                  Copy
```
docker build -t django-ec2-complete .
docker run -p 8000:8080 django-ec2-complete
```
### 3️⃣ Push to AWS ECR

Create an ECR repo and push your Docker image:
ECR will host out built image. This way the server can pull the image and run in production.

First, you’ll need to create an account or login at AWS then we should be good to setup ECR. We’ll also need to install the AWS CLI V2.

Now that we have an AWS account and CLI, lets deploy this image to ECR.
bash Copy
```
aws ecr create-repository --repository-name django-ec2-complete
docker tag ...  # tag image
docker push ... # push to ECR
```
### 4️⃣ Deploy to EC2 with Terraform

✅ Launch:

- EC2 instance

- IAM Role

- Security Groups

- Subnets + VPC

- ECR-authenticated Docker container
```
# Define AWS provider and set the region for resource provisioning

provider "aws" {
  region = "us-east-1"
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

# Subnet within VPC for resource allocation, in availability zone us-east-1a
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Django_EC2_Subnet_1"
  }
}

# Another subnet for redundancy, in availability zone us-east-1b
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
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

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    yum update -y
    yum install -y yum-utils

    # Install Docker
    yum install -y docker
    service docker start

    # Install AWS CLI
    yum install -y aws-cli

    # Authenticate to ECR
    docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) 620457613573.dkr.ecr.us-east-1.amazonaws.com

    # Pull the Docker image from ECR
    docker pull 620457613573.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete:latest

    # Run the Docker image
    docker run -d -p 80:8080 \
    --env SECRET_KEY=${var.secret_key} \
    620457613573.dkr.ecr.us-east-1.amazonaws.com/django-ec2-complete:latest
    EOF

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
```
Initialize and apply:

bash         Copy
```
terraform init
terraform apply
```
### 5️⃣ Connect PostgreSQL on RDS
Let’s create a database.tf file to define the following:

### DB subnet group for RDS instances, using the created subnets
```
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
  engine_version         = "16.1"
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
```
Run the following to set environment variables for db_password and secret_key
Create database.tf:

- aws_db_instance

- aws_db_subnet_group

- rds_sg
  
Use environment variables to connect:

bash  Copy
```
export DB_NAME=djangodb
export DB_USER_NM=adam
```
Update settings.py:

python  Copy
```
DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql',
    'NAME': os.getenv('DB_NAME'),
    ...
  }
}
```
### 6️⃣ Configure Custom Domain & HTTPS
Buy a domain in AWS Route 53 and use Terraform (domain.tf) to:

- Create a load balancer

- Request an ACM cert

- Add DNS records

- Point domain to load balancer

If you want to connect a custom domain, all we need to do is buy a domain on Route53 in AWS and connect it with a domain.tf terraform file.

```
Guys, if you want to use the Free Tier of AWS, then you don't need to use Loud balancer in this project. 
Because it uses paid public IPv4 address, which is not free:

Virtual Private Cloud -

$0.005 per In-use public IPv4 address per hour
```
![DontuseLoadBalancer19](https://github.com/user-attachments/assets/55b1c0bb-579d-4dd1-a469-eb8e148c60ab)


In our domain.tf file, we’ll set up:

- A load balancer to direct public http traffic to our server
- An ACM certificate for https://
- A Route 53 zone (the domain we bought)
- Some AWS Route 53 records - to map this domain to load balancer
With that, let’s add the domain.tf file:

### Request a certificate for the domain and its www subdomain
```
resource "aws_acm_certificate" "cert" {
  domain_name       = "lamorre.com"
  validation_method = "DNS"

  subject_alternative_names = ["www.lamorre.com"]

  tags = {
    Name = "my_domain_certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```
### Declare the Route 53 zone for the domain
```
data "aws_route53_zone" "selected" {
  name = "lamorre.com"
}

```
### Define the Route 53 records for certificate validation
```
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
```
### Define the Route 53 records for the domain and its www subdomain
```
resource "aws_route53_record" "root_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "lamorre.com"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.lamorre.com"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}
```
### Define the certificate validation resource
```
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```
### Security group for ALB, allows HTTPS traffic
```
resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.default.id
  name        = "alb-https-security-group"
  description = "Allow all inbound HTTPS traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
### Application Load Balancer for HTTPS traffic
```
resource "aws_lb" "default" {
  name               = "django-ec2-alb-https"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false
}
```
### Target group for the ALB to route traffic from ALB to VPC
```
resource "aws_lb_target_group" "default" {
  name     = "django-ec2-tg-https"
  port     = 443
  protocol = "HTTP" # Protocol used between the load balancer and targets
  vpc_id   = aws_vpc.default.id
}
```
### Attach the EC2 instance to the target group
```
resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_instance.web.id # Your EC2 instance ID
  port             = 80                  # Port the EC2 instance listens on; adjust if different
}
```

### HTTPS listener for the ALB to route traffic to the target group
```
resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Default policy, adjust as needed
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
```

### Re-run terraform apply:

```
terraform apply --auto-approve
```
### 🚀 To deploy

```
terraform init
terraform apply
```


### ✅ Final Checklist
 - Django project running in Docker

 - Hosted on AWS EC2 via Terraform

 - Secure PostgreSQL via RDS

 - Custom domain on Route 53

 - SSL certificate via ACM

### 🧹 Cleanup
To destroy resources:

bash             Copy
```
terraform destroy
```

### 📚 Documentation

Full documentation is available here:  
👉 [Project Docs on GitHub](https://github.com/mainocean/django_ec2_complete/tree/docs/docs)

This includes:

- Infrastructure setup with Terraform
- Django project deployment
- AWS EC2 integration
- Docker configuration
- Troubleshooting and tips
### 📚 Resources

- Official Django Docs

- AWS CLI Setup
- Terraform AWS Provider

### 🛡️ License
MIT License — Use this freely and modify for your projects.
