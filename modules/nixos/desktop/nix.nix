{ inputs, ... }: {
  environment.etc = {
    "nix/flake-channels/system".source = inputs.self;
    "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
    "nix/flake-channels/nixpkgs-unstable".source = inputs.nixpkgs-unstable;
  };

  nix = {
    # pin the flake registry to flake input
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    };

    settings = {
      # keep build dependencies for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # https://discourse.nixos.org/t/do-flakes-also-set-the-system-channel/19798
      # pin system channels to flake inputs
      nix-path = "nixpkgs=/etc/nix/flake-channels/nixpkgs";
    };
  };
}
