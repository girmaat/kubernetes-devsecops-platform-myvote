variable "cluster_name" {
  type        = string
  description = "Cluster name used for tagging"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to use"
}
