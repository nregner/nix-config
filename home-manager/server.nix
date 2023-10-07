{ inputs, outputs, pkgs, ... }: {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Login shell
  programs.zsh.enable = true;
  users.users.nregner.shell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nregner = {
      imports = [
        #
        ./.
        ./cli
      ];

      home = {
        username = "nregner";
        homeDirectory = "/home/nregner";
      };

      # Nicely reload system units when changing configs
      systemd.user.startServices = "sd-switch";

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      home.stateVersion = "23.05";
    };
    extraSpecialArgs = { inherit inputs outputs; };
  };
}
