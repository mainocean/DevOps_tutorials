#!/bin/bash
set -e

# Variables
AWS_REGION="eu-central-1"
AWS_ACCOUNT_ID="89735666yourID"
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
