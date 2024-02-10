{
  imports = [ ../nixos/base/nix.nix ../nixos/desktop/nix.nix ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    user = "root";
  };
}
