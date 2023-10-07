{ outputs, ... }: {
  imports = [ outputs.homeManagerModules.flake-symlink ];

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}
