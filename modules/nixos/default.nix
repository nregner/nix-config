# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  # List your module files here
  # my-module = import ./my-module.nix;

  base = { pkgs, ... }: {
    system.stateVersion = "22.05";

    # Configure networking
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    # Create user "test"
    services.getty.autologinUser = "test";
    users.users.test.isNormalUser = true;

    # Enable passwordless ‘sudo’ for the "test" user
    users.users.test.extraGroups = [ "wheel" ];
    security.sudo.wheelNeedsPassword = false;
  };
  vm = { ... }: {
    # Make VM output to the terminal instead of a separate window
    virtualisation.vmVariant.virtualisation.graphics = false;
  };
}
