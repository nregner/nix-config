terraform {
  backend "s3" {
    bucket = "terraform-dcdf20ad-dcc3-4477-9ef9-4309d1e04799"
    key    = "nix-config/tailscale"
    region = "us-west-2"
  }
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.10"
    }
  }
}

provider "tailscale" {
  oauth_client_id     = file("/run/secrets/tailscale/client_id")
  oauth_client_secret = file("/run/secrets/tailscale/client_secret")
}