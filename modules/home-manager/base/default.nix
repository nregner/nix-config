{ inputs, options, pkgs, lib, ... }: {
  imports = [
    inputs.catppuccin-nix.homeManagerModules.catppuccin
    ../lib
    ./fzf.nix
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

      programs.ssh = {
        enable = true;
        # https://docs.ssh.com/manuals/server-zos-user/64/disabling-agent-forwarding.html
        forwardAgent = false;
        # share connections
        controlMaster = "auto";
        controlPersist = "10m";
      };

      home.packages = with pkgs.unstable; [ nix-tree nix-du ];
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
