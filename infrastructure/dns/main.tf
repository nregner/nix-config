terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/dns"
    region = "us-west-2"
  }
}

data "aws_route53_zone" "primary" {
  name = "nregner.net"
}

module "acme" {
  source      = "./acme"
  hosted_zone = data.aws_route53_zone.primary
  username    = "sagittarius"
}

module "ddns" {
  source = "./ddns"
  for_each = {
    sagittarius = { subdomain = null }
    voron       = { subdomain = "voron" }
    kraken      = { subdomain = "kraken-*" }
  }
  hosted_zone = data.aws_route53_zone.primary
  username    = each.key
  subdomain   = each.value.subdomain
}

locals {
  secrets = {
    acme = { sagittarius = module.acme.env }
    ddns = { for machine, ddns in module.ddns : machine => ddns.env }
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
