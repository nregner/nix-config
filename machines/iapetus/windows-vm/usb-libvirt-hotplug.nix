# https://github.com/olavmrk/usb-libvirt-hotplug
{ pkgs, lib, ... }:
let
  domain = "win10";
  script = pkgs.writeShellApplication {
    name = "usb-libvirt-hotplug";
    runtimeInputs = [ pkgs.libvirt ];
    text = builtins.readFile ./usb-libvirt-hotplug.sh;
  };
  command = "${lib.getExe script} ${domain}";
in
{
  # find: `udevadm monitor --property --udev --subsystem-match=usb/usb_device`
  # test: `journalctl -f`
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{ID_MODEL}=="InterLinkDX", RUN+="${command}"
  '';
}
