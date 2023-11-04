terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/kms"
    region = "us-west-2"
  }
}

resource "aws_kms_key" "nix_builder_sops" {
  description  = "Nix builder SOPS key"
  multi_region = true
}

resource "aws_kms_key_policy" "nix_builder_sops" {
  key_id = aws_kms_key.nix_builder_sops.id
  policy = jsonencode({
    Statement = [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::544292031362:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
    Version = "2012-10-17"
  })
}

output "nix_builder_sops_kms_key_arn" {
  value = aws_kms_key.nix_builder_sops.arn
}
