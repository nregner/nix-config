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

  super-slicer-latest = (pkgs.super-slicer-latest.override {
    # workaround for `std::binary_function` removal in c++17
    stdenv = pkgs.llvmPackages_11.stdenv;
    boost = pkgs.boost.override { enableStatic = true; };
  }).overrideAttrs (oldAttrs: {
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      ''-DCMAKE_OSX_DEPLOYMENT_TARGET="10.14"''
      "-DSLIC3R_STATIC=1"
      "-DCMAKE_BUILD_TYPE=Debug"
      "-DCMAKE_OSX_ARCHITECTURES:STRING=arm64"
    ];
  });
}

// {
  inherit (pkgs.unstable.callPackage ../machines/print-farm/klipper/firmware
    { })
    klipper-flash-sunlu-s8;
}

