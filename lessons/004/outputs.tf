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


output "ec2_elastic_ip" {
  description = "Elastic IP associated with the EC2 instance"
  value       = aws_eip.django_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance using Elastic IP"
  value       = "ssh -i ~/.ssh/mykey.pem ubuntu@${aws_eip.django_eip.public_ip}"
}

