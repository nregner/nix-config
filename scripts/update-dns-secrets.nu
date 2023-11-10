#!/usr/bin/env nu
terraform -chdir=terraform/dns output -json |
  from json |
  get secrets.value |
  transpose name secrets |
  each { |machine| sops --set $'["route53"] ($machine.secrets | to json -r)' $"nixos/($machine.name)/secrets.yaml" }
