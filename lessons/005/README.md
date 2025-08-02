<p align="center">
  <img src="https://github.com/user-attachments/assets/d27dec6e-fb2a-4046-9e2f-c66fec75a7a4" alt="Project Screenshot" width="1100"/>
</p>


# 🚀 All-in-One Django Deployment to AWS. 
### Full production setup using Docker, EC2, RDS, Route 53, and Terraform.

This project demonstrates how to deploy a Django web application in production on AWS with:

✅ A Dockerized Django app on EC2

✅ A PostgreSQL database hosted on Amazon RDS

✅ Infrastructure managed with Terraform

✅ HTTPS secured with AWS ACM and a custom domain via Route 53

### 📚 Documentation
Full documentation is available here:  
👉 [Project Docs on GitHub](https://github.com/mainocean/DevOps_tutorials/tree/main/lessons/005/docs)

This includes:

- Infrastructure setup with Terraform
- Django project deployment
- AWS EC2 integration
- Docker configuration
- Troubleshooting and tips
### 📚 Resources
- Blog Lamorre
  
  📖 Tutorial reference:
```
https://blog.lamorre.co/django-production/django-ec2-complete
https://www.youtube.com/watch?v=mbUOtILjGgU&ab_channel=AdamLaMorre
```
- Official Django Docs
- AWS CLI Setup
- Terraform AWS Provider

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
### 🚀  Deployment
1️⃣ Start a Django Project

2️⃣ Dockerize the App

3️⃣ Push to AWS ECR

4️⃣ Deploy to EC2 with Terraform

  ✅ Launch:

 - EC2 instance

 - IAM Role

 - Security Groups

 - Subnets + VPC

 - ECR-authenticated Docker container

###  🚀 To deploy

 ```
 terraform init
 terraform apply
 ```
5️⃣ Connect PostgreSQL on RDS

6️⃣ Configure Custom Domain & HTTPS
Buy a domain in AWS Route 53 and use Terraform (domain.tf) to:

 - Create a load balancer

 - Request an ACM cert

 - Add DNS records

 - Point domain to load balancer

If you want to connect a custom domain, all we need to do is buy a domain on Route53 in AWS and connect it with a domain.tf terraform file.
```
Guys, if you want to use the Free Tier of AWS, then you don't need to use Loud balancer in this project. 
Because it uses paid public IPv4 address:

Virtual Private Cloud -

$0.005 per In-use public IPv4 address per hour
```
![DontuseLoadBalancer19](https://github.com/user-attachments/assets/55b1c0bb-579d-4dd1-a469-eb8e148c60ab)



✅ Final Checklist
 - Django project running in Docker

 - Hosted on AWS EC2 via Terraform

 - Secure PostgreSQL via RDS

 - Custom domain on Route 53

 - SSL certificate via ACM

### 🧹 Cleanup
To destroy resources:

```
terraform destroy
```

### 🛡️ License
MIT License — Use this freely and modify for your projects.
