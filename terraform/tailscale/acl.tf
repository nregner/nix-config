# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    groups = {
      "group:admin" = ["nathanregner@gmail.com"]
    }
    tagOwners = {
      "tag:admin"  = ["group:admin"]
      "tag:server" = ["group:admin"]
      "tag:ssh"    = ["group:admin"]
    }

    acls = [
      {
        action = "accept"
        src    = ["group:admin", "tag:admin"]
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
        src    = ["group:admin", "tag:admin"]
        dst    = ["tag:server", "tag:ssh"]
        users  = ["autogroup:nonroot", "root"]
      },
      {
        action = "accept"
        src    = ["tag:server"]
        dst    = ["tag:ssh"]
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

resource "tailscale_dns_search_paths" "default" {
  search_paths = [
    "nregner.net"
  ]
}

output "server_key" {
  value     = tailscale_tailnet_key.server.key
  sensitive = true
}
