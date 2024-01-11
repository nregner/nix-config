{ pkgs, lib }:
lib.recurseIntoAttrs {
  flash-rp2040 = pkgs.callPackage ./rp2040.nix { };
  calibrate-shaper = pkgs.callPackage ./calibrate-shaper.nix { };
} // (lib.recurseIntoAttrs
  (pkgs.callPackage ../../machines/print-farm/klipper/firmware { }))
