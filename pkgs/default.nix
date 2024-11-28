{ inputs, pkgs }:
let
  sources = pkgs.callPackage ../_sources/generated.nix { };
  nodePkgs = pkgs.unstable.nodePackages_latest;
  node2nixPkgs = import ./node2nix {
    pkgs = pkgs.unstable;
    nodejs = nodePkgs.nodejs;
  };
in
{
  inherit (node2nixPkgs) "@olrtg/emmet-language-server" typescript;

  cura5 = pkgs.unstable.callPackage ./cura { inherit sources; };

  gitea-github-mirror = pkgs.unstable.callPackage ./gitea-github-mirror { };

  graphql-language-service-cli = node2nixPkgs.graphql-language-service-cli.override {
    nativeBuildInputs = [ pkgs.unstable.makeWrapper ];
    postInstall = ''
      wrapProgram "$out/bin/graphql-lsp" \
      --prefix NODE_PATH : ${nodePkgs.graphql}/lib/node_modules
    '';
  };

  hammerspoon = pkgs.unstable.callPackage ./hammerspoon.nix { inherit sources; };

  insync = pkgs.unstable.callPackage ./insync.nix { };

  insync-nautilus = pkgs.unstable.callPackage ./insync-nautilus { };

  harper-ls = pkgs.unstable.callPackage ./harper-ls { inherit sources; };

  hydra-auto-upgrade = pkgs.unstable.callPackage ./hydra-auto-upgrade { };

  generate-sops-keys = pkgs.unstable.callPackage ./generate-sops-keys.nix { };

  joker = pkgs.unstable.buildGoModule (
    sources.joker
    // {
      vendorHash = "sha256-t/28kTJVgVoe7DgGzNgA1sYKoA6oNC46AeJSrW/JetU=";
      preBuild = ''
        go generate ./...
      '';
    }
  );

  klipper-calibrate-shaper = pkgs.callPackage ./klipper/calibrate-shaper.nix { };

  klipper-flash-rp2040 = pkgs.callPackage ./klipper/rp2040.nix { };

  orca-slicer = (pkgs.unstable.callPackage ./orca-slicer { inherit sources; });

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  scroll-reverser = pkgs.unstable.callPackage ./scroll-reverser { inherit sources; };

  sf-mono-nerd-font =
    let
      inherit (sources.sf-mono-nerd-font) pname version src;
    in
    pkgs.unstable.runCommand "${pname}-${version}" { } ''
      mkdir -p $out/share/fonts/${pname}
      cp ${src}/*.otf $out/share/fonts/${pname}

    '';

  vtsls = node2nixPkgs."@vtsls/language-server";

  writeBabashkaApplication = pkgs.unstable.callPackage ./write-babashka-application.nix { };
}
