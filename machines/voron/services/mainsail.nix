{ pkgs, lib, ... }:
{
  services.mainsail = {
    enable = true;
    package = pkgs.unstable.mainsail;
  };
  services.nginx = {
    clientMaxBodySize = "1G";
  };

  # systemd.services.ustreamer = {
  #   description = "Mainsail webcam stream";
  #   script = with pkgs; ''
  #     ${ustreamer}/bin/ustreamer --device /dev/video0 --host 0.0.0.0 --port 81
  #   '';
  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = "1s";
  #     RestartSteps = 10;
  #     RestartMaxDelaySec = "1m";
  #   };
  # };

  # # restart ustreamer when webcam is plugged in
  # services.udev.extraRules = ''
  #   ACTION=="add", ENV{SUBSYSTEM}=="video4linux", RUN+="${pkgs.systemd}/bin/systemctl restart ustreamer.service"
  # '';

  services.mediamtx = {
    enable = true;
    allowVideoAccess = true;
    package = pkgs.unstable.mediamtx;
    settings = {
      paths.cam = {
        runOnInit =
          let
            ffmpeg = pkgs.unstable.ffmpeg-headless;
          in
          "${lib.getExe ffmpeg} -f v4l2 -i /dev/video0 -pix_fmt yuv420p -s:v 1920x1080 -r 25 -c:v libx264 -bf 0 -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH";
        runOnInitRestart = true;
      };
      # https://github.com/bluenviron/mediamtx#webrtc-specific-features
      webrtcAdditionalHosts = [
        "voron"
        "voron.nregner.net"
      ];
    };
  };

  environment.systemPackages = with pkgs.unstable; [
    ffmpeg-headless
    # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    # gst_all_1.gst-vaapi
  ];

  networking.firewall =
    let
      ports = [
        80
        8189
        8889
      ];
    in
    {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };
}
