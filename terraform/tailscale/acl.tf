# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    groups = {
      "group:admin" = [
        "nathanregner@gmail.com",
        "regnerbrian@gmail.com",
      ]
    }
    tagOwners = {
      "tag:admin"   = ["nathanregner@gmail.com"]
      "tag:server"  = ["nathanregner@gmail.com"]
      "tag:ssh"     = ["nathanregner@gmail.com"]
      "tag:hydra"   = ["nathanregner@gmail.com"]
      "tag:builder" = ["nathanregner@gmail.com"]
    }
    hosts = {
      sagittarius = data.tailscale_device.sagittarius.addresses[0]
    }

    acls = [
      {
        action = "accept"
        src    = ["group:admin", "tag:admin"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["*"]
        dst = [
          "sagittarius:8000", # binary cache
        ]
      },
      {
        action = "accept"
        src    = ["group:admin", "tag:admin", "tag:server"]
        dst = [
          "sagittarius:9201" # elasticsearch
        ]
      },
      {
        action = "accept"
        src    = ["group:admin", "tag:admin", "sagittarius"]
        dst    = ["tag:builder:22"]
      },
    ]

    # https://tailscale.com/kb/1337/acl-syntax#ssh
    ssh = [
      {
        action = "accept"
        src    = ["group:admin", "tag:admin"]
        dst    = ["tag:builder", "tag:server", "tag:admin"]
        users  = ["autogroup:nonroot", "root"]
      },
      {
        action = "accept"
        src    = ["group:admin", "tag:admin", "tag:hydra"]
        dst    = ["tag:builder"]
        users  = ["autogroup:nonroot", "root"]
      },
    ]
  })
}

