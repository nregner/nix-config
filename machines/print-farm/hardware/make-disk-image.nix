{ nixosConfig, disko, pkgs ? nixosConfig.pkgs, lib ? pkgs.lib
, name ? "${nixosConfig.config.networking.hostName}-disko-images"
, extraPostVM ? "", postInstallScript, checked ? false }:
let
  diskoLib = disko.lib;
  vmTools = pkgs.vmTools.override {
    # rootModules = [ "9p" "9pnet_virtio" "virtio_pci" "virtio_blk" ]
    #   ++ nixosConfig.config.disko.extraRootModules;
    # kernel = pkgs.aggregateModules (with nixosConfig.config.boot.kernelPackages;
    #   [ kernel ]
    #   ++ lib.optional (lib.elem "zfs" nixosConfig.config.disko.extraRootModules)
    #   zfs);
  };
  cleanedConfig = diskoLib.testLib.prepareDiskoConfig nixosConfig.config
    diskoLib.testLib.devices;
  systemToInstallOld = nixosConfig.extendModules {
    modules = [{
      disko.devices = lib.mkForce cleanedConfig.disko.devices;
      boot.loader.grub.devices =
        lib.mkForce cleanedConfig.boot.loader.grub.devices;
    }];
  };

  cleanConfig = x:
    if lib.isAttrs x then
      lib.listToAttrs (lib.concatMap (name:
        if !lib.hasPrefix "_" name then
          [ (lib.nameValuePair name (cleanConfig x.${name})) ]
        else
          [ ]) (lib.attrNames x))
    else if lib.isList x then
      builtins.map cleanConfig x
    else
      x;

  systemToInstall = pkgs.nixos [{
    imports = [ disko.nixosModules.disko ];
    # disko.devices = lib.mkForce cleanedConfig.disko.devices;
    disko.devices.disk = lib.traceValSeq (lib.foldlAttrs
      (acc: diskName: diskConfig: {
        devices = lib.tail acc.devices;
        disk = acc.disk // {
          "${diskName}" = diskConfig // {
            device = lib.head acc.devices;
            content = diskConfig.content // { device = lib.head acc.devices; };
          };
        };
      }) {
        devices =
          [ "/dev/vda" "/dev/vdb" "/dev/vdc" "/dev/vdd" "/dev/vde" "/dev/vdf" ];
        disk = { };
      } (cleanConfig nixosConfig.config.disko.devices.disk)).disk;
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
  }];
  dependencies = with pkgs;
    [
      bash
      coreutils
      gnused
      parted # for partprobe
      systemdMinimal
      nix
      util-linux
      findutils # xargs
    ] ++ nixosConfig.config.disko.extraDependencies;
  preVM = ''
    ${lib.concatMapStringsSep "\n" (disk:
      " ${pkgs.qemu}/bin/qemu-img create -f qcow2 ${disk.name}.qcow2 ${disk.imageSize}")
    (lib.attrValues nixosConfig.config.disko.devices.disk)}
  '';
  postVM = ''
    # shellcheck disable=SC2154
    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n"
    (disk: ''mv ${disk.name}.qcow2 "$out"/${disk.name}.qcow2'')
    (lib.attrValues nixosConfig.config.disko.devices.disk)}
    ${extraPostVM}
  '';
  partitioner = ''
    # running udev, stolen from stage-1.sh
    echo "running udev..."
    ln -sfn /proc/self/fd /dev/fd
    ln -sfn /proc/self/fd/0 /dev/stdin
    ln -sfn /proc/self/fd/1 /dev/stdout
    ln -sfn /proc/self/fd/2 /dev/stderr
    mkdir -p /etc/udev
    ln -sfn ${systemToInstall.config.system.build.etc}/etc/udev/rules.d /etc/udev/rules.d
    mkdir -p /dev/.mdadm
    ${pkgs.systemdMinimal}/lib/systemd/systemd-udevd --daemon
    partprobe
    udevadm trigger --action=add
    udevadm settle

    # populate nix db, so nixos-install doesn't complain
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${
      pkgs.closureInfo {
        rootPaths = [ systemToInstall.config.system.build.toplevel ];
      }
    }/registration

    ${systemToInstall.config.system.build.diskoScript}
  '';

  sdClosureInfo = pkgs.buildPackages.closureInfo {
    rootPaths = [ nixosConfig.config.system.build.toplevel ];
  };
  root = systemToInstall.config.disko.rootMountPoint;
  inherit ((import
    "${nixosConfig.modulesPath}/system/boot/loader/generic-extlinux-compatible" {
      inherit (nixosConfig) pkgs config lib;
    }).config.content.boot.loader.generic-extlinux-compatible)
    populateCmd;
  installer = ''
    echo ${root}
    mkdir -p ${root}/nix/store

    xargs -P 8 -I % cp -a --reflink=auto % -t ${root}/nix/store/ < ${sdClosureInfo}/store-paths
    cp ${sdClosureInfo}/registration ${root}/nix-path-registration

    mkdir -p ${root}/nix/var/nix/profiles
    ${systemToInstall.config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${nixosConfig.config.system.build.toplevel} -d ${root}/boot

    ${populateCmd} -c ${nixosConfig.config.system.build.toplevel} -d "${root}/boot" -g 0

    cp -r --reflink=auto ${postInstallScript}/* -t ${root}

    shrinkBTRFSFs() {
      local mpoint shrinkBy
      mpoint=''${1:-/mnt}

      while :; do
        shrinkBy=$(
          btrfs filesystem usage -b "$mpoint" |
          awk \
            -v fudgeFactor=0.9 \
            -F'[^0-9]' \
            '
              /Free.*min:/ {
                sz = $(NF-1) * fudgeFactor
                print int(sz)
                exit
              }
            '
        )
        btrfs filesystem resize -"$shrinkBy" "$mpoint" || break
      done
      btrfs scrub start -B "$mpoint"
    }

    shrinkLastPartition() {
      local blockDev sizeInK partNum

      blockDev=''${1:-/dev/vda}
      sizeInK=$2

      partNum=$(
        lsblk --paths --list --noheadings --output name,type "$blockDev" |
          awk \
            -v blockdev="$blockDev" \
            '
              # Assume lsblk has output these in order, get the name of
              # last device it identifies as a partition
              $2 == "part" {
                partname = $1
              }

              # Strip out the blockdev so we get just partition number
              END {
                  gsub(blockdev, "", partname)
                  print partname
              }
            '
      )

      echo ",$sizeInK" | sfdisk -N"$partNum" "$blockDev"
      udevadm settle
    }

    shrinkBTRFSFs ${root}
    local sizeInK
    sizeInK=$(
      btrfs filesystem usage -b /mnt |
      awk '/Device size:/ { print ($NF / 1024) "KiB" }'
    )
    shrinkLastPartition /dev/vda "$sizeInK"

    umount -Rv ${root}
  '';
  QEMU_OPTS = lib.concatMapStringsSep " " (disk:
    "-drive file=${disk.name}.qcow2,if=virtio,cache=unsafe,werror=report,format=qcow2")
    (lib.attrValues nixosConfig.config.disko.devices.disk);
in {
  pure = vmTools.runInLinuxVM (pkgs.runCommand name {
    buildInputs = dependencies;
    inherit preVM postVM QEMU_OPTS;
    memSize = nixosConfig.config.disko.memSize;
  } (partitioner + installer));
  impure = diskoLib.writeCheckedBash { inherit checked pkgs; } name ''
    set -efu
    export PATH=${lib.makeBinPath dependencies}
    showUsage() {
    cat <<\USAGE
    Usage: $script [options]

    Options:
    * --pre-format-files <src> <dst>
      copies the src to the dst on the VM, before disko is run
      This is useful to provide secrets like LUKS keys, or other files you need for formating
    * --post-format-files <src> <dst>
      copies the src to the dst on the finished image
      These end up in the images later and is useful if you want to add some extra stateful files
      They will have the same permissions but will be owned by root:root
    * --build-memory <amt>
      specify the ammount of memory that gets allocated to the build vm (in mb)
      This can be usefull if you want to build images with a more involed NixOS config
      By default the vm will get 1024M/1GB
    USAGE
    }

    export out=$PWD
    TMPDIR=$(mktemp -d); export TMPDIR
    trap 'rm -rf "$TMPDIR"' EXIT
    cd "$TMPDIR"

    mkdir copy_before_disko copy_after_disko

    while [[ $# -gt 0 ]]; do
      case "$1" in
      --pre-format-files)
        src=$2
        dst=$3
        cp --reflink=auto -r "$src" copy_before_disko/"$(echo "$dst" | base64)"
        shift 2
        ;;
      --post-format-files)
        src=$2
        dst=$3
        cp --reflink=auto -r "$src" copy_after_disko/"$(echo "$dst" | base64)"
        shift 2
        ;;
      --build-memory)
        regex="^[0-9]+$"
        if ! [[ $2 =~ $regex ]]; then
          echo "'$2' is not a number"
          exit 1
        fi
        build_memory=$2
        shift 1
        ;;
      *)
        showUsage
        exit 1
        ;;
      esac
      shift
    done

    export preVM=${
      diskoLib.writeCheckedBash { inherit pkgs checked; } "preVM.sh" ''
        set -efu
        mv copy_before_disko copy_after_disko xchg/
        ${preVM}
      ''
    }
    export postVM=${
      diskoLib.writeCheckedBash { inherit pkgs checked; } "postVM.sh" postVM
    }
    export origBuilder=${
      pkgs.writeScript "disko-builder" ''
        set -eu
        export PATH=${lib.makeBinPath dependencies}
        for src in /tmp/xchg/copy_before_disko/*; do
          [ -e "$src" ] || continue
          dst=$(basename "$src" | base64 -d)
          mkdir -p "$(dirname "$dst")"
          cp -r "$src" "$dst"
        done
        set -f
        ${partitioner}
        set +f
        for src in /tmp/xchg/copy_after_disko/*; do
          [ -e "$src" ] || continue
          dst=/mnt/$(basename "$src" | base64 -d)
          mkdir -p "$(dirname "$dst")"
          cp -r "$src" "$dst"
        done
        ${installer}
      ''
    }

    build_memory=''${build_memory:-1024}
    QEMU_OPTS=${lib.escapeShellArg QEMU_OPTS}
    QEMU_OPTS+=" -m $build_memory"
    export QEMU_OPTS

    ${pkgs.bash}/bin/sh -e ${vmTools.vmRunCommand vmTools.qemuCommandLinux}
    cd /
  '';

  inherit sdClosureInfo;
  inherit postInstallScript;
  inherit systemToInstall;
}
