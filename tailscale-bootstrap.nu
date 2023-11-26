def main [auth_key: path] {
  let health = tailscale status -json | from json | get Health

  if $health == null {
    echo "Tailscale is healthy, aborting..."
    exit 0
  }

  echo "Tailscale is unhealthy, attempting reconnect..."
  tailscale up --reset --ssh --auth-key="file:${config.sops.secrets.tailscale-auth-key.path}"
}
