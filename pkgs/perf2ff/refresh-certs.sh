#!/usr/bin/env sh

set -xe

openssl req -nodes \
  -x509 \
  -days 3650 \
  -newkey rsa:4096 \
  -keyout localhost.key \
  -out localhost.cert \
  -sha256 \
  -batch \
  -subj "/CN=localhost"
