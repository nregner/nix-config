# derived from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/os-specific/linux/wiringpi/default.nix
{ src, lib, pkgsBuildTarget, symlinkJoin, libxcrypt }:
let
  inherit (pkgsBuildTarget) stdenv;
  version = src.rev;
  mkSubProject = { subprj # The only mandatory argument
    , buildInputs ? [ ] }:
    stdenv.mkDerivation rec {
      pname = "wiringop-${subprj}";
      inherit version src;
      sourceRoot = "source/${subprj}";
      inherit buildInputs;
      enableParallelBuilding = true;
      # Remove (meant for other OSs) lines from Makefiles
      preInstall = ''
        sed -i "/chown root/d" Makefile
        sed -i "/chmod/d" Makefile
        mkdir -p $out/bin
      '';
      makeFlags = [
        "DESTDIR=${placeholder "out"}"
        "PREFIX="
        # On NixOS we don't need to run ldconfig during build:
        "LDCONFIG=echo"
      ];
    };
  passthru = {
    inherit mkSubProject;
    wiringPi = mkSubProject {
      subprj = "wiringPi";
      buildInputs = [ libxcrypt ];
    };
    devLib = mkSubProject {
      subprj = "devLib";
      buildInputs = [ passthru.wiringPi ];
    };
    wiringPiD = mkSubProject {
      subprj = "wiringPiD";
      buildInputs = [ libxcrypt passthru.wiringPi passthru.devLib ];
    };
    gpio = mkSubProject {
      subprj = "gpio";
      buildInputs = [ libxcrypt passthru.wiringPi passthru.devLib ];
    };
  };

in symlinkJoin {
  name = "wiringop-${version}";
  inherit passthru;
  paths =
    [ passthru.wiringPi passthru.devLib passthru.wiringPiD passthru.gpio ];
  meta = with lib; {
    description = "WiringPi port to the Orange Pi family";
    homepage = "https://github.com/orangepi-xunlong/wiringOP";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = [ "aarch64-linux" ];
  };
}
