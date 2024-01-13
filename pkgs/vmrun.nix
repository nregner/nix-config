{ buildPackages }:
let inherit (buildPackages) vmTools writeShellApplication;
in writeShellApplication {
  name = "vmTools";
  text = ''
    ${vmTools.vmRunCommand vmTools.qemuCommandLinux}
  '';
buildContainer {
  args = [
    (with pkgs;
      writeScript "run.sh" ''
        #!${bash}/bin/bash
        exec ${bash}/bin/bash
      '').outPath
  ];

  mounts = {
    "/data" = {
      type = "none";
      source = "/var/lib/mydata";
      options = [ "bind" ];
    };
  };

  readonly = false;
}
