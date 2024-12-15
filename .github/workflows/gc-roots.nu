#!/usr/bin/env nu

let user = $env.USER
let gc_root_base = $"/nix/var/nix/gcroots/per-user/($user)"

export def main [] {
  let base = $"($gc_root_base)"
  ls $base | sort-by -nr name
}

export def "main add" [
  branch: string
  run: int
] {
  let base = $"($gc_root_base)/($branch)/($run)"
  ls result-* | each {
    nix-store --add-root $"($base)/($in.name)" -r $"./($in.name)"
  }
}

export def "main prune" [
  branch: string
  --keep: int = 10
] {
  let base = $"($gc_root_base)/($branch)"
  let sorted = ls $base | sort-by -nr name
  $sorted | skip $keep | each { rm -rv $in.name }
  $sorted | take $keep
}
