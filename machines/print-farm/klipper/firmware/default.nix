{ avrdude, klipper-firmware, writeShellApplication }:
let
  avrdudeNoDoc = avrdude.override { docSupport = false; };
  build-klipper-firmware = firmwareConfig:
    (klipper-firmware.override {
      avrdude = avrdudeNoDoc;
      inherit firmwareConfig;
    }).overrideAttrs (prev: {
      nativeBuildInputs =
        (builtins.filter (pkg: builtins.match "wxwidgets.*" pkg.name == null)
          prev.nativeBuildInputs);
      patches = prev.patches or [ ]
        ++ [ ./0001-Add-default-klipper.elf.hex-target.patch ];
      installPhase = ''
        cp out/klipper.elf.hex $out
      '';
    });
in {
  flash-sunlu-s8 = writeShellApplication {
    name = "klipper-flash-sunlu-s8";
    runtimeInputs = [ avrdudeNoDoc ];
    text = ''
      avrdude -c stk500v2 -p m2560 -P "$1" -D -Uflash:w:${
        (build-klipper-firmware ./sunlu-s8-firmware.cfg)
      }:i
    '';
  };
}
