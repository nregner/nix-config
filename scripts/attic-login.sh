set -x
ssh sagittarius -- \
  sudo atticd-atticadm make-token \
  --sub "$(hostname)" \
  --validity '1y' \
  --push 'default' \
  --pull 'default' \
  --delete 'default' \
  --create-cache 'default' \
  --configure-cache 'default' \
  --configure-cache-retention 'default' \
  --destroy-cache 'default' |
  tail -n 1 |
  tr -d '\r' |
  xargs attic login 'default' 'https://attic.nregner.net'
