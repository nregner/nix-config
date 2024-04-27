{ inputs, ... }: rec {
  additions = final: _prev:
    import ../pkgs {
      inherit inputs;
      pkgs = final;
    };

  modifications = final: prev: {
    # FIXME: hack to bypass "FATAL: Module ahci not found" error
    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    makeModulesClosure = x:
      prev.makeModulesClosure (x // { allowMissing = true; });

    hydra_unstable = prev.hydra_unstable.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        ./hydra/0001-fix-hydra-queue-runner-gets-stuck-while-there-are-it.patch
        ./hydra/0002-fix-restrict-eval-does-not-allow-access-to-git-flake.patch
        ./hydra/0003-feat-add-always_supported_system_types-option.patch
      ];
    });
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      overlays = [ modifications ];
    };
  };
}
