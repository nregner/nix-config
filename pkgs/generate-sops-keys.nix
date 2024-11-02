{
  writeShellApplication,
  stdenv,
  ssh-to-age,
}:
writeShellApplication {
  name = "generate-sops-keys";
  runtimeInputs = [
    ssh-to-age
  ];
  text = ''
    root="${
      if stdenv.isDarwin then "$HOME/Library/Application Support" else "$XDG_CONFIG_HOME"
    }/sops/age"
    mkdir -p "$root"
    ssh-to-age -private-key -i ~/.ssh/id_ed25519 > "$root/keys.txt"
  '';
}
