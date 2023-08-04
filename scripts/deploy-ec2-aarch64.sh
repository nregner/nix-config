export HOST=root@ec2-aarch64
nixos-rebuild switch --fast --flake .#ec2-aarch64 --target-host $HOST --build-host $HOST --use-substitutes
