region             = "us-east-1"
cluster_name       = "myvote-cluster"
availability_zones = ["us-east-1a"]

instance_type    = "t3.medium"
desired_capacity = 1
max_size         = 1
min_size         = 1

key_name      = "myvote-keypair"
node_role_arn = "arn:aws:iam::443370713928:role/EKSNodeRole"
