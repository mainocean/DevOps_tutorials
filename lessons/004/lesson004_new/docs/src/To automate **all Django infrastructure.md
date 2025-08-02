# To automate **all Django infrastructure setup on AWS in one script**

To automate **all Django infrastructure setup on AWS in one script**, including Docker, ECR, EC2, RDS, and optionally Route53, the best approach is to **bundle everything into a structured shell script plus Terraform automation**.

Here’s a high-level overview, followed by a complete solution:

---

### ✅ **Goals of Automation Script**

1. Build and push Docker image to AWS ECR
2. Provision infrastructure with Terraform:
    - VPC, Subnets, EC2, Security Groups
    - RDS PostgreSQL
    - IAM roles and instance profile
3. Configure EC2 to pull and run Docker container with env vars
4. Optionally: Setup Route53 and HTTPS via ACM

---

### 🛠️ Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed
- Docker installed
- Your Django project in root directory (with Dockerfile and requirements.txt)
- Store secrets securely (env vars or a secrets file)

---

### 🚀 `deploy.sh`: The One Script to Rule Them All

```bash
bash
CopyEdit
#!/bin/bash
set -e

# CONFIGURATION
AWS_REGION="us-east-1"
ECR_REPO_NAME="django-ec2-complete"
IMAGE_TAG="latest"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
SECRET_KEY="changeme-secret"
DB_PASSWORD="changeme-db"
TF_VAR_SECRET_KEY=$SECRET_KEY
TF_VAR_DB_PASSWORD=$DB_PASSWORD

# Step 1: Build and Push Docker Image to ECR
echo "🔧 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

echo "🔨 Building Docker image..."
docker build -t $ECR_REPO_NAME:$IMAGE_TAG .

echo "🏷️ Tagging Docker image..."
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URL:$IMAGE_TAG

echo "🚀 Pushing image to ECR..."
aws ecr describe-repositories --repository-names $ECR_REPO_NAME >/dev/null 2>&1 || \
    aws ecr create-repository --repository-name $ECR_REPO_NAME
docker push $ECR_URL:$IMAGE_TAG

# Step 2: Set Terraform Environment Variables
export TF_VAR_secret_key=$SECRET_KEY
export TF_VAR_db_password=$DB_PASSWORD

# Step 3: Terraform Init & Apply
echo "🧱 Initializing Terraform..."
terraform init

echo "⚙️ Applying Terraform..."
terraform apply --auto-approve

# Step 4: Output public IP and RDS DNS
echo "✅ Deployment complete!"
echo "🌐 EC2 Public IP: $(terraform output -raw ec2_public_ip)"
echo "🛢️ RDS Endpoint: $(terraform output -raw rds_endpoint)"

```

---

### 📁 Directory Structure

```
project-root/
│
├── Dockerfile
├── requirements.txt
├── manage.py
├── mysite/         # Django app
├── deploy.sh       # This script
├── main.tf         # Infra (VPC, EC2, IAM, etc.)
├── database.tf     # RDS config
├── domain.tf       # (Optional) Domain config
└── terraform.tfvars (optional if not using env vars)

```

---

### ✅ `terraform output` Recommendations

Add these to `main.tf` or `outputs.tf`:

```hcl
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.default.address
}

```

---

### 🧪 Optional: Test & Migrate via SSH

After deployment:

```bash
ssh -i your-key.pem ec2-user@<public_ip>
docker exec -it <django_container_id> bash
python manage.py migrate
python manage.py createsuperuser

```

---

### 🔒 Optional: Secrets via AWS Secrets Manager

For production, store `SECRET_KEY`, `DB_PASSWORD`, etc., securely using Secrets Manager or SSM.

---

Would you like me to:

- Generate the complete `main.tf`, `database.tf`, and `outputs.tf`?
- Or help convert this into a **fully modular Terraform structure**?
- Or Docker Compose for local testing?

Let me know your preferred format or if you'd like this as a downloadable repo.