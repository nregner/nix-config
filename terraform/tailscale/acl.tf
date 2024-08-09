# https://registry.terraform.io/providers/tailscale/tailscale/latest/docs
# https://tailscale.com/kb/1337/acl-syntax

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
      iapetus     = data.tailscale_device.iapetus.addresses[0]
      enceladus   = data.tailscale_device.enceladus.addresses[0]
      # enceladus-linux-vm = data.tailscale_device.enceladus_linux_vm.addresses[0]
    }

    # https://tailscale.com/kb/1337/acl-syntax#acls
    acls = [
      {
        action = "accept"
        src    = ["group:admin", "tag:admin"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["sagittarius"]
        dst    = ["*:${jsondecode(file("../../globals.json")).services.prometheus.port}"] # prometheus
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

    # https://tailscale.com/kb/1337/acl-syntax#sshtests
    sshTests = [
      {
        src    = "sagittarius"
        dst    = ["enceladus"]
        accept = ["nregner"]
      },
      # {
      #   src    = "sagittarius"
      #   dst    = ["enceladus-linux-vm"]
      #   accept = ["builder"]
      # },
      {
        src    = "sagittarius"
        dst    = ["iapetus"]
        accept = ["nregner"]
      },
    ]
  })
}

