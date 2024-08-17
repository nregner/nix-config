{ lib, ... }:
{
  imports = [
    ./vfio.nix
    ./usb-libvirt-hotplug.nix
  ];
  virtualisation.libvirtd.enable = true;
  vfio.enable = lib.mkDefault true;
  specialisation."novfio".configuration = {
    system.nixos.tags = [ "no-vfio" ];
    vfio.enable = false;
  };
}
