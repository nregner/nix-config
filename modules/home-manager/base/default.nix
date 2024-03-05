{
  imports = [
    #
    ../lib
    ./fzf.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    frequency = "weekly";
  };
}
