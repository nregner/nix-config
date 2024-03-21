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
          "tag:server:8000", # binary cache
          "tag:server:7125", # moonraker
        ]
      },
      {
        action = "accept"
        src    = ["tag:hydra"]
        dst    = ["tag:builder:22"]
      },
    ]

    # https://tailscale.com/kb/1337/acl-syntax#ssh
    ssh = [
      {
        action = "accept"
        src    = ["group:admin", "tag:admin"]
        dst    = ["tag:server", "tag:server", "tag:admin"]
        users  = ["autogroup:nonroot", "root"]
      },
      {
        action = "accept"
        src    = ["tag:hydra"]
        dst    = ["tag:builder"]
        users  = ["autogroup:nonroot"]
      },
    ]
  })
}

