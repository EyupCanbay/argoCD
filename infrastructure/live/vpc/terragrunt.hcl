include "root" {
    path = find_in_parent_folders()
}

terraform {
    source = "tfr:///terraform-aws-modules/vpc/aws?version=5.7.0"
}

inputs = {
    name = "online-boutique-lab-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["eu-central-1a", "eu-central-1b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
    
    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = true

    enable_dns_hostname = true
    enable_dns_support = true

    public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    }
    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }  
}