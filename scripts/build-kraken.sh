nix build .\#nixosConfigurations.kraken.config.system.build.sdImage \
  --eval-store auto \
  --builders-use-substitutes \
  --json \
  --print-build-logs \
  $@ \
  |& nom
