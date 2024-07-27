{ sources, config, ... }:
let
  port = "9000";
  dataDir = "/var/lib/mealie";
in
{
  # https://docs.mealie.io/documentation/getting-started/installation/sqlite/
  virtualisation.oci-containers.containers.mealie = rec {
    imageFile = sources.mealie.src;
    image = "${imageFile.imageName}:${imageFile.imageTag}"; # pinned image will be loaded from store
    # https://docs.mealie.io/documentation/getting-started/installation/backend-config/
    environment = {
      BASE_URL = "https://mealie.nregner.net";
      API_PORT = port;
      TZ = config.time.timeZone;
      TOKEN_TIME = toString (14 * 24);
      # DATA_DIR = dataDir;
    };
    ports = [ "${port}:${port}" ];
    volumes = [ "${dataDir}:/app/data" ];
  };

  nginx.subdomain.mealie = {
    "/".proxyPass = "http://127.0.0.1:${port}/";
  };

  services.nregner.backup.paths.mealie = {
    paths = [ dataDir ];
    restic = {
      s3 = { };
    };
  };
}
