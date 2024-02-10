#!/usr/bin/env nu

def add_root [store_path: string, tag: string] {
    ssh sagittarius -- $"
        root=\"/nix/var/nix/gcroots/per-user/$USER/($tag)\"
        dir=\"$\(dirname \$root\)\"
        mkdir -p \"$dir\"
        ln -sfn ($store_path) \"$root\"
        echo \"linked $root\"
    "
}

export def "main current-system" [machine: string] {
    let path = (ssh $machine -- realpath /run/current-system)
    echo $"copying ($path)"
    nix copy --from $"ssh-ng://($machine)" --to ssh-ng://sagittarius $path
    add_root $path $"($machine)/$\(cat ($path)/nixos-version\)"
}

export def "main toplevel" [machine: string] {
    let path = (nix build $".#nixosConfigurations.($machine).config.system.build.toplevel" --print-out-paths --no-link)
    echo $"copying ($path)"
    nix copy --to ssh-ng://sagittarius $path --derivation
    add_root $path $"($machine)/(cat $"($path)/nixos-version")"
}

export def main [
    path: string
    --tag: string
    ...args: string
] {
    let path = (realpath $path)
    echo $"copying ($path)"
    nix copy --to ssh-ng://sagittarius $path ...$args
    if ($tag != null) {
        add_root $path $"misc/($tag)"
    }
}
