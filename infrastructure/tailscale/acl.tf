# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    groups = {
      "group:admin" = ["nathanregner@gmail.com"]
    }
    tagOwners = {
      "tag:server" = ["group:admin"]
    }

    acls = [
      {
        action = "accept"
        src    = ["group:admin"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["tag:server"]
        dst = [
          "tag:server:8080",  # atticd
          "tag:server:19999", # netdata
        ]
      }
    ]

    ssh = [
      {
        action = "accept"
        src    = ["group:admin"]
        dst    = ["tag:server"]
        users  = ["autogroup:nonroot", "root"]
      }
    ]
  })
}

resource "tailscale_tailnet_key" "server" {
  description   = "Server automatic registration key"
  ephemeral     = false
  expiry        = null
  preauthorized = true
  reusable      = true
  tags          = ["tag:server"]
}

output "server_key" {
  value     = tailscale_tailnet_key.server.key
  sensitive = true
}
