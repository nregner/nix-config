{ inputs, pkgs }: {
  default =
    pkgs.mkShell { packages = with pkgs.unstable; [ colmena sops terraform ]; };

  bootstrap = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs.unstable; [ nix git ];
    packages = with pkgs.unstable;
      [
        inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
      ];
  };

  rust = pkgs.mkShell { packages = with pkgs; [ cargo rustfmt ]; };
}
