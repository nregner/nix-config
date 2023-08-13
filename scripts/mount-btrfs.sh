sudo mount -o noatime,subvol=@ /dev/sdb2 /mnt
sudo mkdir -p /mnt/{home,var/lib,var/log,nix}
sudo mount -o noatime,subvol=@home /dev/sdb2 /mnt/home
sudo mount -o noatime,subvol=@var-lib /dev/sdb2 /mnt/var/log
sudo mount -o noatime,subvol=@var-log /dev/sdb2 /mnt/var/lib
sudo mount -o noatime,subvol=@nix /dev/sdb2 /mnt/nix
