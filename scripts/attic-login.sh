ssh sagittarius -- \
  sudo atticd-atticadm make-token \
    --sub 'admin' \
    --validity '1y' \
    --create-cache 'default' \
    --push 'default' \
    --pull 'default' \
    --delete 'default' \
  | tail -n 1 \
  | tr -d '\r' \
  | xargs attic login 'default' 'http://sagittarius:8080'

