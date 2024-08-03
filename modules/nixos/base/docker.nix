{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.docker = {
    package = pkgs.unstable.docker_27;
    rootless = {
      package = config.virtualisation.docker.package;
    };
  };

  warnings = (
    lib.optional (lib.versionOlder config.virtualisation.docker.package.version pkgs.unstable.docker.version) "`services.docker.package` is outdated (${config.virtualisation.docker.package.version} < ${pkgs.unstable.docker.version})"
  );
}
