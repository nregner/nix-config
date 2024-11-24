{
  self,
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];
  formatAttr = "isoImage";
  fileExtension = ".iso";

  environment.etc."nixos/flake".source = self.outPath;
  environment.systemPackages = [
    # copy system closure so we don't have to download/rebuild on the host
    # config.system.build.toplevel
    (pkgs.runCommand "install-scripts" { } ''
      mkdir -p $out/bin
      cp ${config.system.build.formatScript} $out/bin/disko-format
      cp ${config.system.build.mountScript} $out/bin/disko-mount
      cp ${pkgs.writeShellScript "install" ''
        sudo nixos-install --root /mnt --flake ${self.outPath}
      ''} $out/bin/nixos-install-flake
    '')
  ];
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
}
