{ lib, ... }: {
  imports = [ ./route53-ddns.nix ./tailscale-bootstrap.nix ];
  services.tailscale-bootstrap.enable = lib.mkDefault true;
}
