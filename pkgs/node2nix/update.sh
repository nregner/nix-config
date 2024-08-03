#!/usr/bin/env bash
cd "$(dirname "$0")"
node2nix -i node-packages.json --include-peer-dependencies
