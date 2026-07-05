include "root" { path = find_in_parent_folders() }

terraform { source = "../../modules/argocd-install" }

dependency "eks" {
  config_path = "../eks"
  mock_outputs = { cluster_name = "mock-cluster" }
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
}