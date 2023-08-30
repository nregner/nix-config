terraform -chdir=infrastructure/ddns output -json \
  | jq -r '.aws_env.value | to_entries | .[] | "echo \"\(.value)\" | EDITOR=\"cp -f /dev/stdin\" sops -input-type dotenv machines/\(.key)/secrets/ddns.env"' \
  | bash
