# https://nixos.wiki/wiki/Go
{ lib, buildGoModule, mkShell, go }:
let
  pkg = buildGoModule {
    pname = "gitea-github-mirror";
    version = "1.0.0";

    src = lib.cleanSource ./.;
    vendorHash = "sha256-/EebKxlfpaUfSpGQ7+GXByuv1lG7Na9rzuFKy7ONSFk=";
    passthru.devShell =
      mkShell { packages = pkg.nativeBuildInputs ++ pkg.buildInputs; };
  };
in pkg

