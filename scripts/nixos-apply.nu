#!/usr/bin/env nu

export def main [
    host: string
    path: string
] {
    echo $"deploying ($path) to ($host)"
    ssh $host -- $"
        nix copy --from https://cache.nregner.net ($path) &&
        sudo nix-env -p /nix/var/nix/profiles/system --set ($path) &&
        sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    "
}
