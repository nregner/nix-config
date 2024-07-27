{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      extensions = [ pkgs.aws-cli-sso ];
      settings = {
        extensions.autoDisableScopes = 0;
      };
    };
  };
}
