server_key=$(terraform -chdir=infrastructure/tailscale output -json \
  | jq -r '.server_key.value')
echo "$server_key"
sops --set "[\"tailscale\"][\"server-key\"] \"$server_key\"" common/server/secrets.yaml
