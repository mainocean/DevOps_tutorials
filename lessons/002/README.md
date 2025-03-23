![alt text](image.png)
# Create GKE Cluster using Terraform
Hi, guys. As you know GKE is a managed Kubernetes platform. Here I am using IaC Terraform to deploy a GKE cluster from a refactored code from GitHub. It used to be free when you were using a single zone. You can use a standard GKE cluster that manages groups of instances for you, or you can use GKE Autopilot, which is a serverless cluster. This means that when you create a package, GKE will create a dedicated node specifically for that module.
If you just compare the prices of compute resources, the difference can be significant, but there are many approaches to a typical Kubernetes cluster. So Autopilot can actually help reduce that. However, it will generally be more expensive than standard GKE. I would say that if you only have a few applications, you can try GKE Autopilot. But if you are dealing with large Kubernetes clusters with 200 or even 300 nodes, you will almost always want to go with the standard cluster because it will be much cheaper. In this case, we only need to create a GKE cluster and a node group.

You can find tutorial [here](https://www.youtube.com/watch?v=P0FuqXlS_ow&ab_channel=DevOps).

# COMMANDS:
terraform init
terraform plan
terraform apply
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials demo --zone us-central1-a --project mythic-handler-454014-e6
kubectl get svc
kubectl get nodes
kubectl auth can-i "*" "*"
terraform destroy