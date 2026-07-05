include "root" { path = find_in_parent_folders() }

terraform { source = "../../modules/vault-kms" }

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_name      = "mock-cluster"
    oidc_provider_arn = "arn:aws:iam::111122223333:oidc-provider/mock"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-central-1.amazonaws.com/id/MOCK"
  }
}

inputs = {
  cluster_name      = dependency.eks.outputs.cluster_name
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url = dependency.eks.outputs.cluster_oidc_issuer_url
}