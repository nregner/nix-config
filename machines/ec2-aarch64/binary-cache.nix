{ config, ... }: {
  sops.secrets."cache-priv-key.pem" = { };

  # TODO: Make this a shared module
  nix = {
    settings = {
      secret-key-files = config.sops.secrets."cache-priv-key.pem".path;
    };
  };
}
