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
export DB_IP=my-django-rds.///////.amazonaws.com
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
# python manage.py runserver

sleep 3
echo "✅ Setup complete. Visit: http://127.0.0.1:8000/ and http://127.0.0.1:8000/admin"

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

echo "✅ Setup complete. Visit: http://localhost:8000"

