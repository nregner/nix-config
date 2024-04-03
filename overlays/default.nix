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
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      overlays = [ modifications ];
    };
  };
}
