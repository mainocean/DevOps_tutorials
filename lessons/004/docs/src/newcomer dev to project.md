# Connect newcomer developer to project on GitHub

To **quickly onboard a new developer** with a laptop running **Ubuntu (clean system)** into your Django project hosted on **GitHub**, we should give them a **scripted and minimal-effort setup process**.

Here’s a **clean, automated, step-by-step setup process** that you can share with the developer as a single shell script or series of commands, which:

- Installs required packages
- Clones the project from GitHub
- Sets up the virtual environment
- Installs dependencies
- Runs the project in Docker (as your setup is dockerized)

---

## Promote new developer:

- all responsibility(.pub GitHub key, add his email to privat branch on GitHub, other exports)

✅ Setup Script for New Developer (Ubuntu)

You can save this as `setup_project.sh` and ask them to run it with:

```bash
bash setup_project.sh
```

---

```bash
#!/bin/bash

# === SYSTEM SETUP ===
echo "Updating system and installing essentials..."
sudo apt update && sudo apt install -y python3.12 python3.12-venv python3.12-dev python3-pip docker.io git tree

# === CHECK PYTHON INSTALLATION ===
if ! python3.12 --version; then
    echo "Python 3.12 not found"
    exit 1
fi

# === GIT CLONE PROJECT ===
echo "Cloning the GitHub repository..."
git clone https://github.com/mainocean/django-ec2-complete.git
cd django-ec2-complete || { echo "Project directory not found"; exit 1; }

# === SETUP VIRTUAL ENVIRONMENT ===
echo "Creating and activating virtual environment..."
python3.12 -m venv venv
source venv/bin/activate

# === INSTALL PYTHON DEPENDENCIES ===
pip install --upgrade pip
pip install -r requirements.txt

# === BUILD DOCKER IMAGE ===
echo "Building Docker image..."
docker build -t django-ec2-complete:latest .

# === RUN DOCKER CONTAINER ===
echo "Running Docker container on http://localhost:8000 ..."
docker run -d -p 8000:8080 django-ec2-complete:latest

# === SHOW TREE STRUCTURE ===
tree -L 2

echo "✅ Setup complete. Visit: http://localhost:8000"

```

---

If you **don’t want the developer handling infrastructure (ECR, RDS, Terraform)**, stop there.

But if the dev needs AWS access:

1. Share temporary **AWS credentials** (via `.env`, `secrets.tfvars`, or `aws configure`)
2. Add these to `~/.bashrc`:

```bash
bash
CopyEdit
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="eu-central-1"

```

Then they can run:

```bash
bash
CopyEdit
terraform init
terraform apply -var-file="secrets.tfvars" -auto-approve

```

---

## ✅ After Setup

Instruct them:

```bash
bash
CopyEdit
# To stop the server
docker ps
docker kill <container_id>

# To re-run
docker run -p 8000:8080 django-ec2-complete:latest

# To go inside the container
docker exec -it <container_id> bash

```

---

## 📦 Final GitHub Tips

In the GitHub repo, create a file:

📄 `DEVELOPER_SETUP.md`

With the same instructions as above. This way, any new developer will always know what to do.