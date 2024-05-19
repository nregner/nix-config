{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.jellyfin;
  };

  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };
  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs.unstable; [
  #     intel-media-driver
  #     vaapiIntel
  #     vaapiVdpau
  #     libvdpau-va-gl
  #     intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
  #   ];
  # };
}
