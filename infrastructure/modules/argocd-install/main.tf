# 1. Provider versiyonlarını açıkça belirtiyoruz ki hata almayalım
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }
  }
}

data "aws_eks_cluster" "eks" { name = var.cluster_name }
data "aws_eks_cluster_auth" "eks" { name = var.cluster_name }

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# 2. Uyarıyı (Warning) çözmek için _v1 kullanıyoruz
resource "kubernetes_namespace_v1" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.11"
  
  # _v1 referansını güncelledik
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}