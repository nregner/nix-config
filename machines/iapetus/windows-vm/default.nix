{
  imports = [
    ./vfio.nix
    ./usb-libvirt-hotplug.nix
  ];
  virtualisation.libvirtd.enable = true;
  vfio.enable = true;
  # specialisation."VFIO".configuration = {
  #   system.nixos.tags = [ "with-vfio" ];
  #   vfio.enable = true;
  # };
}
