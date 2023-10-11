# https://nixos.wiki/wiki/Go
{ lib, buildGoModule }:
buildGoModule {
  pname = "gitea-github-mirror";
  version = "1.0.0";

  src = lib.cleanSource ./.;
  vendorHash = "sha256-xYnqmocBUM/0bgUtien9Mrjix3n5eJ/A0UYpU6mRXAQ=";
}

