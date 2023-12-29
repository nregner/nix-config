{ inputs, pkgs }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix git ];
    packages = with pkgs; [ colmena home-manager sops terraform ];
  };

  rust = pkgs.mkShell { packages = with pkgs; [ cargo rustfmt ]; };
}
