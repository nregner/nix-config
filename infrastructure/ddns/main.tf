terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/dns"
    region = "us-west-2"
  }
}

resource "aws_iam_user" "nix_ddns" {
  name = "nix-ddns"
}

resource "aws_iam_access_key" "nix_ddns" {
  user = aws_iam_user.nix_ddns.name
}

output "aws_access_key_id" {
  value = aws_iam_access_key.nix_ddns.id
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.nix_ddns.secret
  sensitive = true
}

data "aws_iam_policy_document" "nix_ddns" {
  statement {
    effect  = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*",]
  }
}

resource "aws_iam_policy" "nix_ddns" {
  policy = data.aws_iam_policy_document.nix_ddns.json
}

resource "aws_iam_policy_attachment" "nix_ddns" {
  name       = "nix-ddns"
  policy_arn = aws_iam_policy.nix_ddns.arn
  users      = [aws_iam_user.nix_ddns.name]
}