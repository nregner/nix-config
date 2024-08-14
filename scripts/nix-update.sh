#!/usr/bin/env bash

# Source: https://discourse.nixos.org/t/25274
prefix="$(readlink --canonicalize -- "$(dirname -- "$0")/../pkgs")"
echo $prefix
nixpkgs="$(nix flake metadata nixpkgs --json | jq .path -r)"

exec nix-shell "$nixpkgs/maintainers/scripts/update.nix" \
  --arg include-overlays 'builtins.attrValues (builtins.getFlake (toString ./.)).overlays' \
  --arg predicate "(
    let prefix = \"$prefix\"; prefixLen = builtins.stringLength prefix;
    in (_: p: (builtins.substring 0 prefixLen p.meta.position) == prefix)
  )"
