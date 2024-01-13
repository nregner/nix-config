{ lib, pkgs, config, postVM ? "", size ? "2048M", includeChannel ? false
, postInstallScript ? "", compress ? false, emulateUEFI ? false, memory ? 1024,
}:
let
  compressArgs = if compress then "-c" else "";
  channelSources = let nixpkgs = lib.cleanSource pkgs.path;
  in pkgs.runCommand "nixos-${config.system.nixos.version}" { } ''
    mkdir -p $out
    cp -prd ${nixpkgs.outPath} $out/nixos
    chmod -R u+w $out/nixos
    if [ ! -e $out/nixos/nixpkgs ]; then
      ln -s . $out/nixos/nixpkgs
    fi
    rm -rf $out/nixos/.git
    echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
  '';

  closureInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ]
      ++ (lib.optional includeChannel channelSources);
  };

  modulesTree =
    pkgs.aggregateModules (with config.boot.kernelPackages; [ kernel zfs ]);

  tools = lib.makeBinPath (with pkgs; [
    config.system.build.nixos-enter
    config.system.build.nixos-install
    dosfstools
    e2fsprogs
    gptfdisk
    nix
    parted
    util-linux
    zfs
  ]);

  qemu = pkgs.buildPackages.qemu.override { toolsOnly = true; };

  diskPaths = builtins.map (disk: disk.device)
    (builtins.attrValues config.disko.devices.disk);
  diskNames = builtins.attrNames config.disko.devices.disk;

  OVMF_CODE = "${pkgs.OVMF.fd}/" + (if pkgs.system == "x86_64-linux" then
    "FV/OVMF_CODE.fd"
  else
    "FV/AAVMF_CODE.fd");
  OVMF_VARS = "${pkgs.OVMF.fd}/" + (if pkgs.system == "x86_64-linux" then
    "FV/OVMF_VARS.fd"
  else
    "FV/AAVMF_VARS.fd");

  images = (pkgs.vmTools.override {
    # rootModules = [
    #   "virtio_pci"
    #   "virtio_mmio"
    #   "virtio_blk"
    #   "virtio_balloon"
    #   "virtio_rng"
    #   "ext4"
    #   "unix"
    #   "9p"
    #   "9pnet_virtio"
    #   "crc32c_generic"
    # ] ++ [ "zfs" ]
    #   ++ (pkgs.lib.optional pkgs.stdenv.hostPlatform.isx86 "rtc_cmos");
    # kernel = modulesTree;
  }).runInLinuxVM (pkgs.runCommand "${config.system.name}" {
    memSize = memory;
    QEMU_OPTS = lib.strings.escapeShellArgs (lib.lists.flatten ((builtins.map
      (diskName: [
        "-drive"
        "file=${
          builtins.baseNameOf diskName
        }.qcow2,if=virtio,cache=unsafe,werror=report"
      ]) diskNames) ++ (lib.optionals emulateUEFI [
        #"-pflash" "${OVMF_CODE}"
        #"-bios" "${OVMF_CODE}"
        "-smbios"
        "type=0,uefi=on"
        "-smbios"
        "type=1,uuid=43d206e8-14eb-4011-bbba-be831e68e032"
        "-drive"
        "if=pflash,unit=0,format=raw,readonly=on,file=${OVMF_CODE}"
        "-drive"
        "if=pflash,unit=1,format=qcow2,id=drive-efidisk0,file=efidisk.qcow2"
      ])));
    preVM = ''
      set -x
      PATH=$PATH:${qemu}/bin
      mkdir -p $out

    '' + (lib.strings.optionalString emulateUEFI ''
      echo "Creating efidisk.qcow2 from ${OVMF_VARS} with size 64M"
      ${qemu}/bin/qemu-img convert -cp -f raw -O qcow2 ${OVMF_VARS} efidisk.qcow2
      ${qemu}/bin/qemu-img resize efidisk.qcow2 64M
    '') + ''

      for disk_image in ${toString (map baseNameOf diskNames)}; do
        echo "Creating ''${disk_image}.qcow2 with size ${toString size}"
        ${qemu}/bin/qemu-img create -f qcow2 "''${disk_image}.qcow2" ${
          toString size
        }
      done
    '';

    postVM = ''
      set -x

      ${lib.strings.optionalString emulateUEFI ''
        echo Compressing efidisk.qcow2
        ${qemu}/bin/qemu-img convert -cp -f qcow2 -O qcow2 efidisk.qcow2 ''${out}/efidisk.qcow2
      ''}

      for disk_image in ${toString (map baseNameOf diskNames)}; do
        echo Compressing "''${disk_image}.qcow2"
        ${qemu}/bin/qemu-img convert -p -f qcow2 -O qcow2 ${compressArgs} "''${disk_image}.qcow2" "''${out}/''${disk_image}.qcow2"
      done
      ${postVM}
    '';
  } (''
    export PATH=${tools}:$PATH
    set -x

    ${lib.strings.optionalString emulateUEFI ''
      # Mount efivars
      mount -t efivarfs efivarfs /sys/firmware/efi/efivars
    ''}

    # Create symlinks with disko device paths pointing to /dev/vdX
    # It's stupid, but it works
    local_disks=( /dev/vd{a..z} )
    index=0
    for to in ${toString diskPaths}; do
      from="''${local_disks[$index]}"
      if [ "$from" == "$to" ]; then continue; fi
      mkdir -p $( dirname $( realpath -s "$to" ) )
      ln -vs "''${from}" "''${to}"
      for i in $(seq 0 10); do
        ln -vs "''${from}''${i}" "''${to}''${i}"
        ln -vs "''${from}''${i}" "''${to}p''${i}"
        ln -vs "''${from}''${i}" "''${to}-part''${i}"
      done
      index=$(( $index + 1 ))
    done

    # Run disko-create
    ${config.system.build.formatScript}
    # Run disko-mount
    ${config.system.build.mountScript}

    # Install NixOS

    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${closureInfo}/registration

    nixos-install \
      -v \
      --root /mnt \
      --no-root-passwd \
      --substituters "" \
      --option binary-caches "" \
      --keep-going \
      --system ${config.system.build.toplevel} \
      ${lib.optionalString includeChannel "--channel ${channelSources}"}

    # Run postInstallScript
    ${postInstallScript}

    # Clean /tmp
    find /mnt/tmp -mindepth 1 -delete

    # Clean up disk from unused sectors
    fstrim -av

    # Unmount all filesystems
    umount -Rv /mnt || :

    # Trim and export all zfs zpools
    for zpool in ${toString (builtins.attrNames config.disko.devices.zpool)}; do
      echo Trimming zpool "$zpool"
      zpool trim -w "$zpool"
      echo Exporting zpool "$zpool"
      zpool export "$zpool"
    done

    # Disconnect all volume groups
    # for zpool in ''${toString ( builtins.attrNames (lib.attrValues config.disko.devices.zpool))}; do

    # done
  ''));
in { inherit images; }
