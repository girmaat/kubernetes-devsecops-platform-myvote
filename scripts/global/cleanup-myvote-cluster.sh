#!/bin/bash

set -uo pipefail

CLUSTER_NAME="myvote-quick-cluster"
REGION="us-east-1"

echo "🧼 RETRYING FULL CLEANUP for EKS cluster: $CLUSTER_NAME in $REGION"

retry() {
  local attempt=0
  local max_attempts=3
  local delay=5
  until "$@"; do
    attempt=$(( attempt + 1 ))
    if (( attempt == max_attempts )); then
      echo "❌ Failed after $max_attempts attempts: $*"
      return 1
    fi
    echo "🔁 Retry $attempt/$max_attempts for: $*"
    sleep $delay
  done
}


# Delete Key Pair
KEY_NAME="myvote-keypair"
echo "🔐 Deleting EC2 Key Pair: $KEY_NAME"
retry aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" || echo "⚠️ Key pair $KEY_NAME not deleted"

# Delete NAT Gateways
NAT_IDS=$(aws ec2 describe-nat-gateways --region "$REGION" --query "NatGateways[].NatGatewayId" --output text)
for nat in $NAT_IDS; do
  echo "🧨 Deleting NAT Gateway: $nat"
  retry aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region "$REGION" || echo "⚠️ NAT Gateway $nat not deleted"
done

# Release Elastic IPs
EIPS=$(aws ec2 describe-addresses --region "$REGION" --query "Addresses[].AllocationId" --output text)
for eip in $EIPS; do
  echo "🌐 Releasing EIP: $eip"
  retry aws ec2 release-address --allocation-id "$eip" --region "$REGION" || echo "⚠️ EIP $eip not released"
done

# Detach and delete Internet Gateways
IGW_IDS=$(aws ec2 describe-internet-gateways --region "$REGION" --query "InternetGateways[].InternetGatewayId" --output text)
for igw in $IGW_IDS; do
  VPC_ID=$(aws ec2 describe-internet-gateways --internet-gateway-ids "$igw" --region "$REGION" --query "InternetGateways[0].Attachments[0].VpcId" --output text)
  if [ "$VPC_ID" != "None" ]; then
    echo "🔌 Detaching IGW $igw from VPC $VPC_ID"
    retry aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$VPC_ID" --region "$REGION" || echo "⚠️ IGW $igw could not be detached"
  fi
  echo "❌ Deleting IGW: $igw"
  retry aws ec2 delete-internet-gateway --internet-gateway-id "$igw" --region "$REGION" || echo "⚠️ IGW $igw not deleted"
done

# Delete Load Balancers (ELBv2)
ALB_ARNs=$(aws elbv2 describe-load-balancers --region "$REGION" --query "LoadBalancers[].LoadBalancerArn" --output text)
for alb in $ALB_ARNs; do
  echo "🗑 Deleting ALB: $alb"
  retry aws elbv2 delete-load-balancer --load-balancer-arn "$alb" --region "$REGION" || echo "⚠️ ALB $alb not deleted"
done

# Delete Route Tables
RT_IDS=$(aws ec2 describe-route-tables --region "$REGION" --query "RouteTables[].RouteTableId" --output text)
for rt in $RT_IDS; do
  echo "🛣 Deleting Route Table: $rt"
  retry aws ec2 delete-route-table --route-table-id "$rt" --region "$REGION" || echo "⚠️ Route table $rt not deleted"
done

# Delete Subnets
SUBNET_IDS=$(aws ec2 describe-subnets --region "$REGION" --query "Subnets[].SubnetId" --output text)
for subnet in $SUBNET_IDS; do
  echo "📦 Deleting Subnet: $subnet"
  retry aws ec2 delete-subnet --subnet-id "$subnet" --region "$REGION" || echo "⚠️ Subnet $subnet not deleted"
done

# Delete Network ACLs
NACL_IDS=$(aws ec2 describe-network-acls --region "$REGION" --query "NetworkAcls[?Default==\`false\`].NetworkAclId" --output text)
for nacl in $NACL_IDS; do
  echo "🛡 Deleting NACL: $nacl"
  retry aws ec2 delete-network-acl --network-acl-id "$nacl" --region "$REGION" || echo "⚠️ NACL $nacl not deleted"
done

# Delete Security Groups
SG_IDS=$(aws ec2 describe-security-groups --region "$REGION" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
for sg in $SG_IDS; do
  echo "🚫 Deleting Security Group: $sg"
  retry aws ec2 delete-security-group --group-id "$sg" --region "$REGION" || echo "⚠️ SG $sg not deleted"
done

# Delete VPCs
VPC_IDS=$(aws ec2 describe-vpcs --region "$REGION" --query "Vpcs[].VpcId" --output text)
for vpc in $VPC_IDS; do
  echo "🏗 Deleting VPC: $vpc"
  retry aws ec2 delete-vpc --vpc-id "$vpc" --region "$REGION" || echo "⚠️ VPC $vpc not deleted"
done

echo "✅ RETRY CLEANUP SCRIPT FINISHED"
