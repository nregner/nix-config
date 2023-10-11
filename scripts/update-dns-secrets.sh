terraform -chdir=terraform/dns output -json \
  | jq -r '.secrets.value | to_entries | .[]
    | "sops --set '\''[\"route53\"] \(.value)'\'' machines/\(.key)/secrets.yaml"' \
  | bash
