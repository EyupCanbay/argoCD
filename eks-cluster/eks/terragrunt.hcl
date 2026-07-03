include "root" {
    path = find_in_parent_folders()
}

terraform {
    source = "."
}

dependency "vpc" {
    config_path = "../vpc"

    mock_outputs = {
    vpc_id          = "vpc-mock-id"
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
    }
}

inputs = {
    cluster_name    = "ob-lab-eks"
    cluster_version = "1.34"
    
    vpc_id     = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets
}

