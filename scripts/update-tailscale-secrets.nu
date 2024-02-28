let secrets = terraform -chdir=terraform/tailscale output -json |
  from json |
  transpose name value |
  update value { |secret| $secret.value.value } |
  transpose -r -d

sops --set $'["tailscale"] ($secrets | to json -r)' "modules/nixos/server/secrets.yaml"
