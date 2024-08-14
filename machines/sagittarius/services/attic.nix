{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 8083;
in
{
  imports = [ inputs.attic.nixosModules.atticd ];

  users = {
    groups.atticd = { };
    users.atticd = {
      group = "atticd";
      isSystemUser = true;
    };
  };

  sops.secrets.atticd = {
    key = "atticd";
    owner = config.users.users.atticd.name;
    group = "wheel";
    mode = "0440";
  };

  services.atticd = {
    enable = true;
    package = pkgs.unstable.attic-server;
    user = config.users.users.atticd.name;
    credentialsFile = config.sops.secrets.atticd.path;

    settings = {
      listen = "[::]:${toString port}";

      database.url = "postgresql:///attic?host=/run/postgresql";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 0;

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024;

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024;

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024;
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "attic" ];
    ensureUsers = [ { name = "atticd"; } ];
  };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    $PSQL -tAc 'ALTER DATABASE "attic" OWNER TO "atticd"'
  '';

  nginx.subdomain.attic = {
    "/".proxyPass = "http://127.0.0.1:${toString port}/";
  };
}
