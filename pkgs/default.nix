# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }: {
  inherit (inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}) attic;

  gitea-github-mirror = pkgs.unstable.callPackage ./gitea-github-mirror { };

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  netdata-latest = pkgs.unstable.callPackage ./netdata.nix { };

  # jetbrains-toolbox = pkgs.unstable.callPackage ./jetbrains-toolbox.nix { };

  # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  freecad-link = let inherit (pkgs.unstable) freecad ccacheStdenv;
  in (freecad.override { stdenv = ccacheStdenv; }).overrideAttrs (prev: {
    version = inputs.freecad.rev;
    src = inputs.freecad;
    nativeBuildInputs = [ ccacheStdenv.cc ] ++ prev.nativeBuildInputs;
  });

  conform-nvim = pkgs.unstable.vimUtils.buildVimPlugin {
    pname = "conform.nvim";
    version = inputs.conform-nvim.rev;
    src = inputs.conform-nvim;
    meta.homepage = "https://github.com/stevearc/conform.nvim";
    # the Makefile non-deterministically pulls git repos for linting/testing - don't need it
    postPatch = "rm Makefile";
  };

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit inputs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}

