{ config, ... }: {
  sops.secrets = let
    common = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
    };
  in {
    "tailscale/client_id" = common // {
      key = "client_id";
      path = "${config.home.homeDirectory}/run/secrets/tailscale/client_id";
    };
    "tailscale/client_secret" = common // {
      key = "client_secret";
      path = "${config.home.homeDirectory}/run/secrets/tailscale/client_secret";
    };
  };
}
