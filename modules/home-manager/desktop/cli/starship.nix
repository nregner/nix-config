{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    catppuccin.enable = true;
    # https://starship.rs/config
    settings = {
      # Move directory to the second line
      format = "$all$directory$character";
      package.disabled = true;
      aws.disabled = true;
      nix_shell.disabled = true;
      docker_context = {
        only_with_files = false;
      };
      direnv = {
        # disabled = false;
        symbol = "";
        style = "bold blue";
      };
    };
  };
}
