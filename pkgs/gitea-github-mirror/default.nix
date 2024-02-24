# https://nixos.wiki/wiki/Go
{ lib, buildGoModule }:
buildGoModule {
  pname = "gitea-github-mirror";
  version = "1.0.0";

  src = lib.cleanSource ./.;
  vendorHash = "sha256-Gn51V04kyDHD9JNiDZq9pUaYGvjSaHFyWjtTVNNoMqY=";
}

