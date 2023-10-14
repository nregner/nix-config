# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs ? (import ./nixpkgs.nix) { } }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix git ];
    allowUnfree = true;
    packages = with pkgs; [ deploy-rs home-manager sops terraform just ];
  };

  rust = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    packages = with pkgs; [ cargo rustfmt ];
  };
}
