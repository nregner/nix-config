{ self, inputs, outputs, config, lib, ... }:

with lib;

let
  inherit (pkgs) stdenv;

  cfg = config.nix.linux-builder-2;

  system = "aarch64-darwin";
  inherit (inputs) nixpkgs;
  pkgs = nixpkgs.legacyPackages."${system}";

  darwin-builder =
    let toGuest = builtins.replaceStrings [ "darwin" ] [ "linux" ];
    in nixpkgs.lib.nixosSystem {
      system = null;
      specialArgs = { inherit self inputs outputs; };

      modules = [{
        imports = [ "${nixpkgs}/nixos/modules/profiles/macos-builder.nix" ]
          ++ [ cfg.config ];

        # If you need to override this, consider starting with the right Nixpkgs
        # in the first place, ie change `pkgs` in `pkgs.darwin.linux-builder`.
        # or if you're creating new wiring that's not `pkgs`-centric, perhaps use the
        # macos-builder profile directly.
        virtualisation.host = { inherit pkgs; };

        nixpkgs.hostPlatform =
          lib.mkDefault (toGuest stdenv.hostPlatform.system);
      }];
    };

  # create-builder uses TMPDIR to share files with the builder, notably certs.
  # macOS will clean up files in /tmp automatically that haven't been accessed in 3+ days.
  # If we let it use /tmp, leaving the computer asleep for 3 days makes the certs vanish.
  # So we'll use /run/org.nixos.linux-builder instead and clean it up ourselves.
  script = pkgs.writeShellScript "linux-builder-start" ''
    export TMPDIR=/run/org.nixos.linux-builder USE_TMPDIR=1
    rm -rf $TMPDIR
    mkdir -p $TMPDIR
    trap "rm -rf $TMPDIR" EXIT
    ${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder
  '';

in {
  options.nix.linux-builder-2 = {
    enable = mkEnableOption (lib.mdDoc "Linux builder");

    package = mkOption { default = darwin-builder; };

    config = mkOption {
      type = types.deferredModule;
      default = { };
      example = literalExpression ''
        ({ pkgs, ... }:

        {
          environment.systemPackages = [ pkgs.neovim ];
        })
      '';
      description = lib.mdDoc ''
        This option specifies extra NixOS configuration for the builder. You should first use the Linux builder
        without changing the builder configuration otherwise you may not be able to build the Linux builder.
      '';
    };

    maxJobs = mkOption {
      type = types.ints.positive;
      default = 1;
      example = 4;
      description = lib.mdDoc ''
        This option specifies the maximum number of jobs to run on the Linux builder at once.

        This sets the corresponding `nix.buildMachines.*.maxJobs` option.
      '';
    };

    supportedFeatures = mkOption {
      type = types.listOf types.str;
      default = [ "kvm" "benchmark" "big-parallel" ];
      description = lib.mdDoc ''
        This option specifies the list of features supported by the Linux builder.

        This sets the corresponding `nix.buildMachines.*.supportedFeatures` option.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.nix.settings.trusted-users != [ "root" ]
        || (config.nix.settings.extra-trusted-users or [ ]) != [ ];
      message = ''
        Your user or group (@admin) needs to be added to `nix.settings.trusted-users` or `nix.settings.extra-trusted-users`
        to use the Linux builder.
      '';
    }];

    system.activationScripts.preActivation.text = ''
      mkdir -p /var/lib/darwin-builder
    '';

    launchd.daemons.linux-builder = {
      environment = {
        inherit (config.environment.variables) NIX_SSL_CERT_FILE;
        QEMU_OPTS =
          "-virtfs local,path=/Volumes/dev,security_model=mapped,mount_tag=dev";
      };
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path /nix/store &amp;&amp; exec ${script}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        WorkingDirectory = "/var/lib/darwin-builder";
      };
    };

    environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = ''
      Host m3-linux-builder
        Hostname localhost
        HostKeyAlias m3-linux-builder
        Port 31022
    '';

    nix.distributedBuilds = true;

    nix.buildMachines = [{
      hostName = "m3-linux-builder";
      sshUser = "builder";
      sshKey = "/etc/nix/builder_ed25519";
      system = "${stdenv.hostPlatform.uname.processor}-linux";
      publicHostKey =
        "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
      inherit (cfg) maxJobs supportedFeatures;
    }];

    nix.settings.builders-use-substitutes = true;

    # system.build.darwin-builder = darwin-builder;
  };
}
