#!/usr/bin/env nu
terraform -chdir=terraform/dns output -json |
  from json |
  get secrets.value |
  transpose name secrets |
  each { |machine| sops --set $'["route53"] ($machine.secrets | to json -r)' $"machines/($machine.name)/secrets.yaml" }
