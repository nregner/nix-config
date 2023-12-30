# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }:
{
  gitea-github-mirror = pkgs.unstable.callPackage ./gitea-github-mirror { };

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  netdata-latest = pkgs.unstable.callPackage ./netdata.nix { };

  # disable xvfb-run tests
  xdot-darwin = (pkgs.unstable.xdot.overridePythonAttrs
    (oldAttrs: { nativeCheckInputs = [ ]; })).overrideAttrs
    (oldAttrs: { doInstallCheck = false; });

  prepare-sd-card = pkgs.writeShellApplication {
    name = "prepare-sd-card";
    runtimeInputs = with pkgs; [ gnutar zstd ];
    text = ''
      tmp=$(mktemp -d)
      img="$tmp/sd-card.img"
      mnt="$tmp/mnt"

      sudo mkdir -p "$mnt"
      unzstd "$1" -o "$img"
      sudo mount -o loop,offset=39845888 "$img" "$mnt"
      sudo mkdir -p "$mnt/etc/ssh/"
      sudo tar -axf "$2" -C "$mnt/etc/ssh/"
      sudo umount "$mnt"

      echo "$tmp"
    '';
  };
}

//

(let
  build-klipper-firmware = firmwareConfig:
    (pkgs.unstable.klipper-firmware.override {
      avrdude = pkgs.avrdude.override { docSupport = false; };
      inherit firmwareConfig;
    }).overrideAttrs (prev: {
      nativeBuildInputs =
        (builtins.filter (pkg: builtins.match "wxwidgets.*" pkg.name == null)
          prev.nativeBuildInputs);
      patches = prev.patches or [ ]
        ++ [ ./0001-Add-default-klipper.elf.hex-target.patch ];
      installPhase = ''
        ${prev.installPhase or ""}
        cp out/klipper.elf.hex $out/klipper.elf.hex
      '';
    });
in {
  klipper-firmware-sunlu-s8 = let
    firmware = build-klipper-firmware ../machines/kraken/klipper/firmware.cfg;
  in firmware // {
    passthru.klipper-flash = pkgs.writeShellApplication {
      name = "klipper-flash-sunlu-s8";
      runtimeInputs = [ (pkgs.avrdude.override { docSupport = false; }) ];
      text = ''
        avrdude -c stk500v2 -p m2560 -P "$1" -D -Uflash:w:${firmware}/klipper.elf.hex:i
      '';
    };
  };

  klipper-firmare-voron-2_4 =
    build-klipper-firmware ../machines/voron/firmware.cfg;
})

