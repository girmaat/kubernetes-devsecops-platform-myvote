1. eksctl-cluster.yaml
### Purpose of the yaml file
This configuration is used to:
    Provision a custom VPC with public/private subnets
    Deploy an EKS control plane
    Set up managed node groups
    Attach IAM policies to Kubernetes service accounts (IRSA)
    Enable critical EKS add-ons: CoreDNS, kube-proxy, VPC CNI
    Configure CloudWatch logging for audit and visibility

### Usage
Dry-run Preview
    eksctl create cluster --dry-run -f eksctl-cluster.yaml

### Create the Cluster
    eksctl create cluster -f eksctl-cluster.yaml --verbose 4
This will create:
    A new EKS control plane
    VPC, subnets, route tables, NAT and IGW
    IAM roles, node groups, and service accounts

### Cleanup 
To delete the entire cluster and its managed resources:
    eksctl delete cluster --name myvote-cluster --region us-east-1

Note: This will not delete unmanaged resources or orphaned EIPs, ENIs, or IAM roles. Use a cleanup script for full teardown.

2. cluster-info.yaml 
After creating the cluster, run the following to capture its metadata:
    eksctl get cluster --region us-east-1 -o yaml > cluster-info.yaml
    The command exports Cluster Snapshot  to cluster-info.yaml file