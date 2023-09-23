{ outputs, ... }: {
  imports = [ outputs.homeManagerModules.flake-symlink ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      # Workaround for https=//github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}