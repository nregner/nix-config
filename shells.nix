{ inputs, pkgs }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix git ];
    packages = with pkgs; [
      inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
      home-manager
      sops
      terraform
    ];
  };

  rust = pkgs.mkShell { packages = with pkgs; [ cargo rustfmt ]; };
}
