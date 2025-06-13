variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where nodes should be launched"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the worker nodes"
}

variable "desired_capacity" {
  type        = number
}

variable "max_size" {
  type        = number
}

variable "min_size" {
  type        = number
}

variable "key_name" {
  type        = string
  description = "Name of SSH key pair for EC2 access"
}

variable "node_role_arn" {
  type        = string
  default     = ""
  description = "Optional pre-created IAM role for the node group"
}
