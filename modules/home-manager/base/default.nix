{ options, lib, ... }: {
  imports = [
    #
    ../lib
    ./fzf.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
  ];

  # TODO: Remove check when home-manager is updated to 24.11
  config = lib.mkMerge [
    (lib.optionalAttrs (builtins.hasAttr "gc" options.nix) {
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 7d";
        frequency = "weekly";
      };
    })
  ];
}
