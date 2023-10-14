{
  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tools
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # Themes
    catppuccin-alacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };
    catppuccin-papirus-folders = {
      url = "github:catppuccin/papirus-folders";
      flake = false;
    };
    catppuccin-lazygit = {
      url = "github:catppuccin/lazygit";
      flake = false;
    };

    # Misc
    # https://github.com/realthunder/FreeCAD/releases
    freecad = {
      url = "github:realthunder/FreeCAD/LinkMerge";
      flake = false;
    };

    linux-rockchip = {
      url = "github:armbian/linux-rockchip/rk-5.10-rkr4";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, deploy-rs, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forEachNode = lib.trivial.pipe 4 [
        (lib.lists.range 1)
        (map (n: "kraken-${toString n}"))
        lib.genAttrs
      ];
    in rec {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit inputs pkgs; });

      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs-unstable { inherit system; }
            // ((import ./nixos/common/global/nixpkgs.nix) {
              inherit outputs;
            }).nixpkgs;
        in import ./shell.nix { inherit pkgs; });

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#'
      nixosConfigurations = {
        iapetus = lib.nixosSystem {
          specialArgs = { inherit self inputs outputs; };
          modules = [ ./nixos/iapetus/configuration.nix ];
        };

        sagittarius = lib.nixosSystem {
          specialArgs = { inherit self inputs outputs; };
          modules = [ ./nixos/sagittarius/configuration.nix ];
        };

        # Builder VM
        ec2-aarch64 = lib.nixosSystem {
          specialArgs = { inherit self inputs outputs; };
          modules = [ ./nixos/ec2-aarch64/configuration.nix ];
          system = "aarch64-linux";
        };

        # Voron 2.4r2 Klipper machine
        voron = lib.nixosSystem {
          specialArgs = { inherit self inputs outputs; };
          modules = [ ./nixos/voron/configuration.nix ];
          system = "aarch64-linux";
        };
      } // forEachNode (hostname:
        # 3d print farm node
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit self inputs outputs nixpkgs hostname; };
          modules = [ ./nixos/kraken/configuration.nix ];
          system = "aarch64-linux";
        });

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#'
      homeConfigurations = {
        "nregner@iapetus" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
            inherit (pkgs) targetPlatform;
          };
          modules = [ ./home-manager/iapetus.nix ];
        };
      };

      # TODO: Derive from nixosConfigurations
      deploy.nodes = forEachNode (hostname: {
        inherit hostname;
        fastConnection = false;
        remoteBuild = false;
        profiles.system = {
          path = deploy-rs.lib.aarch64-linux.activate.nixos
            self.nixosConfigurations.${hostname};
        };
      }) // {
        ec2-aarch64 = (let hostname = "ec2-aarch64";
        in {
          inherit hostname;
          fastConnection = true;
          remoteBuild = true;
          sshUser = "root";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos
              self.nixosConfigurations.${hostname};
          };
        });
        voron = (let hostname = "voron";
        in {
          inherit hostname;
          fastConnection = false;
          remoteBuild = true;
          sshUser = "nregner";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos
              self.nixosConfigurations.${hostname};
          };
        });
        sagittarius = (let hostname = "sagittarius";
        in {
          inherit hostname;
          fastConnection = false;
          remoteBuild = true;
          sshUser = "nregner";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.${hostname};
          };
        });
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
