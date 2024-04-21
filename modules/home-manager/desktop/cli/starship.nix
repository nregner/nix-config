{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    catppuccin.enable = true;
    settings = {
      # Move directory to the second line
      format = "$all$directory$character";
      package.disabled = true;
      aws.disabled = true;
      nix_shell.disabled = true;
      docker_context = { only_with_files = false; };
      custom.direnv = {
        detect_files = [ ".envrc" ];
        when = ''[[ $(direnv status) =~ " Found RC allowed true " ]]'';
        format = "[ direnv](bold blue)";
      };
    };
  };
}
