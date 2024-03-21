data "tailscale_device" "iapetus" {
  hostname = "iapetus"
}

resource "tailscale_device_tags" "iapetus" {
  device_id = data.tailscale_device.iapetus.id
  tags      = ["tag:admin", "tag:builder"]
}

data "tailscale_device" "sagittarius" {
  hostname = "sagittarius"
}

resource "tailscale_device_tags" "sagittarius" {
  device_id = data.tailscale_device.sagittarius.id
  tags      = ["tag:hydra", "tag:server"]
}

data "tailscale_device" "m3_linux_builder" {
  hostname = "m3-linux-builder-vm"
}

resource "tailscale_device_tags" "m3_linux_builder" {
  device_id = data.tailscale_device.m3_linux_builder.id
  tags      = ["tag:builder"]
}

data "tailscale_device" "m3_darwin_builder" {
  hostname = "enceladus"
}

resource "tailscale_device_tags" "m3_darwin_builder" {
  device_id = data.tailscale_device.m3_darwin_builder.id
  tags      = ["tag:admin", "tag:builder"]
}
