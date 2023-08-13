NIX_SSHOPTS='-p 10022' nixos-rebuild switch --fast --flake ".#sagittarius" \
  --build-host nregner@localhost \
  --target-host nregner@localhost \
  --use-remote-sudo 
