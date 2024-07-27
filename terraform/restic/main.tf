terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/restic"
    region = "us-west-2"
  }
}

module "s3" {
  source      = "./s3"
  bucket_name = "nregner-restic"
}

module "iam" {
  source = "./iam"
  for_each = toset([
    "iapetus",
    "print-farm",
    "sagittarius",
    "voron",
  ])
  bucket_arn = module.s3.bucket_arn
  username   = each.key
}

locals {
  secrets = {
    s3_env = { for machine, iam in module.iam : machine => iam.env }
  }
  machines = toset(flatten([for _, machines in local.secrets : keys(machines)]))
}

output "secrets" {
  value = {
    for machine in local.machines :
    machine =>
    { for secret, machines in local.secrets :
      secret => machines[machine]
      if contains(keys(machines), machine)
    }
  }
  sensitive = true
}
