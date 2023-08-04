nixos-rebuild switch --fast --flake ".#$1" \
  --target-host "$1" \
  --use-remote-sudo \
  --builders "$1" \
  --use-substitutes
