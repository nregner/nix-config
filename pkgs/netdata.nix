{ pkgs }:
pkgs.netdata.overrideAttrs (oldAttrs: rec {
  # https://github.com/netdata/netdata/releases
  version = "1.42.4";
  src = pkgs.fetchFromGitHub {
    owner = "netdata";
    repo = "netdata";
    rev = "v${version}";
    hash = "sha256-8L8PhPgNIHvw+Dcx2D6OE8fp2+GEYOc9wEIoPJSqXME=";
    fetchSubmodules = true;
  };
  # FIXME: Typo in nixpkgs                                                                          
  # enableParallelBuild = true;                                                                       
  enableParallelBuilding = true;
})
