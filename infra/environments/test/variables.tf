variable "region" {}
variable "cluster_name" {}
variable "availability_zones" {
  type = list(string)
}
variable "instance_type" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "key_name" {}
variable "node_role_arn" { default = "" }
