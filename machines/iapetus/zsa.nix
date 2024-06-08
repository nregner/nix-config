{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.unstable; [
    keymapp
    google-chrome
  ];

  services.udev.extraRules = builtins.readFile ./zsa.rules;

  users = {
    groups.plugdev = { };
    users.nregner.extraGroups = [ "plugdev" ];
  };
}
