{ inputs, options, lib, ... }: {
  imports = [
    inputs.catppuccin-nix.homeManagerModules.catppuccin
    ../lib
    ./fzf.nix
    ./starship.nix
    ./tmux-sessionizer.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
  ];

  config = lib.mkMerge [
    {
      # theme
      catppuccin = {
        flavour = "mocha";
        accent = "blue";
      };
    }
    # TODO: Remove check when home-manager is updated to 24.11
    (lib.optionalAttrs (builtins.hasAttr "gc" options.nix) {
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 7d";
        frequency = "weekly";
      };
    })
  ];
}
