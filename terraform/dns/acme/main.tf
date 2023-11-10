variable "hosted_zone" {
  type = object({
    arn     = string
    zone_id = string
    name    = string
  })
}

variable "username" {
  type = string
}

locals {
  username = "${var.username}-nix-acme"
}

resource "aws_iam_user" "nix_acme" {
  name = local.username
}

resource "aws_iam_access_key" "nix_acme" {
  user = aws_iam_user.nix_acme.name
}

# https://go-acme.github.io/lego/dns/route53/
data "aws_iam_policy_document" "nix_acme" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ListResourceRecordSets"]
    resources = [var.hosted_zone.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [var.hosted_zone.arn]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        "_acme-challenge.${var.hosted_zone.name}",
        "_acme-challenge._.${var.hosted_zone.name}"
      ]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }
  }
}

resource "aws_iam_policy" "nix_acme" {
  policy = data.aws_iam_policy_document.nix_acme.json
}

resource "aws_iam_policy_attachment" "nix_acme" {
  name       = local.username
  policy_arn = aws_iam_policy.nix_acme.arn
  users      = [aws_iam_user.nix_acme.name]
}

# https://go-acme.github.io/lego/dns/route53/#credentials
output "env" {
  value     = <<EOT
AWS_HOSTED_ZONE_ID=${var.hosted_zone.zone_id}
AWS_ACCESS_KEY_ID=${aws_iam_access_key.nix_acme.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.nix_acme.secret}
AWS_DEFAULT_REGION=us-west-2
AWS_PROPAGATION_TIMEOUT=600
EOT
  sensitive = true
}
