{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = null;
    profiles.default = {
      # about:debugging#/runtime/this-firefox
      extensions = [
        (pkgs.stdenv.mkDerivation {
          name = "aws-cli-sso";
          src = ./aws-cli-sso;
          nativeBuildInputs = [ pkgs.web-ext ];
          buildPhase = ''
            web-ext build
          '';
          installPhase = ''
            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install -v -m644 "web-ext-artifacts/aws_cli_sso-1.0.zip" "$dst/${"{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"}.xpi"
          '';
        })
      ];

      settings = {
        extensions.autoDisableScopes = 0;
      };
    };
  };
}
