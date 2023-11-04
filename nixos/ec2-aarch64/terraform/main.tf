terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/machines/ec2-aarch64"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/kms"
    region = "us-west-2"
  }
}

resource "aws_instance" "aarch64_builder" {
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/amazon-ec2-amis.nix#L585
  ami                  = "ami-0d0979d889078d036"
  instance_type        = "c7g.4xlarge"
  key_name             = aws_key_pair.ssh.key_name
  iam_instance_profile = aws_iam_instance_profile.nix_builder.name
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 64
    delete_on_termination = false
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "ec2-aarch64-nix"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk7uVEehfyhAZUvZbvH5Kw85MzLyYqVdTOMBXsmBeLx"
}

resource "aws_iam_instance_profile" "nix_builder" {
  name = "nix-builder"
  role = aws_iam_role.nix_builder.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "nix_builder" {
  name                = "nix-builder"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [aws_iam_policy.nix_builder.arn]
}

data "aws_iam_policy_document" "nix_builder" {
  statement {
    sid = "KMS"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [data.terraform_remote_state.kms.outputs.nix_builder_sops_kms_key_arn]
  }
}

resource "aws_iam_policy" "nix_builder" {
  name   = "nix-builder"
  policy = data.aws_iam_policy_document.nix_builder.json
}
