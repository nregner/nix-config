{ config, ... }: {
  sops.secrets = let
    common = {
      sopsFile = ./secrets/oauth.yaml;
      owner = config.users.users.nregner.name;
      mode = "0400";
    };
  in {
    "tailscale/client_id" = common // { key = "client_id"; };
    "tailscale/client_secret" = common // { key = "client_secret"; };
  };
}
