terraform output -json \
  | jq 'map_values(.value)' \
  | sops -e /dev/stdin --input-type json > secrets.json
