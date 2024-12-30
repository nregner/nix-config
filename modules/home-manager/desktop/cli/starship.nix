{
  # catppuccin.starship.enable = true;
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # https://starship.rs/config
    settings = {
      aws.disabled = true;
      nix_shell = {
        symbol = "❄️";
        heuristic = true;
      };
      docker_context.only_with_files = false;
      package.disabled = true;
    };
  };
}
