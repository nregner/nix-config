{ config, pkgs, lib, ... }: {
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
  };

  xdg.configFile."wezterm/user.lua".source =
    config.lib.file.mkFlakeSymlink ./wezterm.lua;

  xdg.configFile."wezterm/wezterm.lua".text = lib.mkForce ''
    local config = require("user")
    -- https://wezfurlong.org/wezterm/config/lua/config/term.html?h=term
    config.set_environment_variables = {
      TERMINFO_DIRS = '${config.home.homeDirectory}/.nix-profile/share/terminfo',
      WSLENV = 'TERMINFO_DIRS',
    }
    return config
  '';
}
