#!/usr/bin/env nu

def add_root [store_path: string, tag: string] {
    ssh sagittarius -- $"
        root=\"/nix/var/nix/gcroots/per-user/$USER/($tag)\"
        dir=\"$\(dirname \$root\)\"
        mkdir -p \"$dir\"
        rm -i \"$root\"
        ln -srf ($store_path) \"$root\"
        echo \"linked $root\"
    "
}

export def "main system" [machine: string] {
    let path = (ssh $machine -- realpath /run/current-system)
    echo $"copying ($path)"
    nix copy --from $"ssh://($machine)" --to ssh://sagittarius $path
    add_root $path $"($machine)/$\(cat ($path)/nixos-version\)"
}

export def main [
    path: string
    --tag: string
    ...args: string
] {
    let path = (realpath $path)
    echo $"copying ($path)"
    nix copy --to ssh://sagittarius $path ...$args
    if ($tag != null) {
        add_root $path $"misc/($tag)"
    }
}
