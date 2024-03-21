terraform {
  required_providers {
    hydra = {
      version = "~> 0.1"
      source  = "DeterminateSystems/hydra"
    }
  }
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/hydra"
    region = "us-west-2"
  }
}

provider "hydra" {
  host = "https://hydra.nregner.net"
}

resource "hydra_project" "nix-config" {
  name         = "nix-config"
  display_name = "nix-config"
  owner        = "nregner"
  enabled      = true
  visible      = true

  declarative {
    file  = ".hydra/spec.json"
    type  = "git"
    value = "https://github.com/nathanregner/nix-config.git hydra"
  }
}
