{
  imports = [
    ../nixos/base/nix.nix
    ../nixos/desktop/nix.nix
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    user = "root";
  };

  # https://github.com/NixOS/nix/issues/4119#issuecomment-1734738812
  nix.settings.sandbox = false;
}
