{
  pkgs,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
}:

# TODO: Remove once https://github.com/NixOS/nixpkgs/pull/319501 is merged
assert !(builtins.hasAttr "vtsls" pkgs);

buildNpmPackage rec {
  pname = "vtsls";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "yioneko";
    repo = "vtsls";
    rev = "server-v${version}";
    hash = "sha256-rHiH42WpKR1nZjsW+Q4pit1aLbNIKxpYSy7sjPS0WGc=";
    fetchSubmodules = true;
  };

  sourceRoot = "${src.name}/packages/server";

  npmDeps = importNpmLock {
    npmRoot = "${src}/packages/server";
    packageLock = lib.importJSON ./package-lock.json;
  };

  npmDepsHash = "sha256-rHiH42WpKR1nZjsW+Q4pit1aLbNIKxpYSy7sjPS0WGc=";

  npmConfigHook = importNpmLock.npmConfigHook;

  dontNpmPrune = true;
}
