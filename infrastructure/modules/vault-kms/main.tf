resource "aws_kms_key" "vault" {
  description             = "Vault Auto-Unseal Key for ${var.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_iam_role" "vault_kms_role" {
  name = "${var.cluster_name}-vault-kms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:vault:vault"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "vault_kms_policy" {
  name = "VaultKMSUnsealPolicy"
  role = aws_iam_role.vault_kms_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["kms:Encrypt", "kms:Decrypt", "kms:DescribeKey"]
      Resource = aws_kms_key.vault.arn
    }]
  })
}

output "kms_key_id" { value = aws_kms_key.vault.key_id }
output "iam_role_arn" { value = aws_iam_role.vault_kms_role.arn }