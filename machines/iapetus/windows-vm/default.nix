{ lib, ... }: {
  imports = [ ./vfio.nix ./usb-libvirt-hotplug.nix ];
  virtualisation.libvirtd.enable = true;
  vfio.enable = true;

  specialisation."NO_VFIO".configuration = {
    system.nixos.tags = [ "no-vfio" ];
    vfio.enable = lib.mkForce false;
  };

  nixpkgs.overlays = [
    (final: prev: {
      qemu = prev.qemu.overrideAttrs (prev: {
        patches = prev.patches ++ [
          ./0001-prevent-evdev-passthrough-from-being-captured-on-gue.patch
        ];
      });
    })
  ];
}
