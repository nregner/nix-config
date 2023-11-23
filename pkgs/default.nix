# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }: {
  gitea-github-mirror = pkgs.unstable.callPackage ./gitea-github-mirror { };

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  netdata-latest = pkgs.unstable.callPackage ./netdata.nix { };

  # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  freecad-link = pkgs.freecad.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-link";
    version = inputs.freecad.rev;
    src = inputs.freecad;
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.fmt ];
  });

  conform-nvim = pkgs.unstable.vimUtils.buildVimPlugin {
    pname = "conform.nvim";
    version = inputs.conform-nvim.rev;
    src = inputs.conform-nvim;
    meta.homepage = "https://github.com/stevearc/conform.nvim";
    # the Makefile non-deterministically pulls git repos for linting/testing - don't need it
    postPatch = "rm Makefile";
  };

  klipper-flash = let
    vendor = "1d50";
    product = "614e";
    firmwareConfig = ../nixos/voron/firmware.cfg;
    firmware = (pkgs.unstable.klipper-firmware.override {
      inherit firmwareConfig;
    }).overrideAttrs {
      # patches = [ ../klipper-firmware.patch ];
      installPhase = ''
        mkdir -p $out
        cp -r out/* $out/
        cp ./.config $out/config
        cp out/klipper.bin $out/ || true
        cp out/klipper.elf $out/ || true
      '';
    };
  in (pkgs.unstable.klipper-flash.override {
    klipper-firmware = firmware;
    flashDevice = "${vendor}:${product}";
    inherit firmwareConfig;
  }).overrideAttrs (oldAttrs: { passthru = { inherit firmware; }; });
}
