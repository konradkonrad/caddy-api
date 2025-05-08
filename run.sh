#!/usr/bin/env bash

mkdir -p data/caddy/{keys,locks,rate_limit/instances}

openssl ecparam -genkey -name prime256v1 -noout \
  -out data/caddy/keys/sign_key.pem
openssl ec -in data/caddy/keys/sign_key.pem -pubout \
  -out data/caddy/keys/verify_key.pem

docker run --rm -it \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
    caddy-api /usr/bin/caddy fmt --overwrite /etc/caddy/Caddyfile

docker run --rm -it \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro \
    -p 8080:8080 \
    -v $(pwd)/data:/data \
    -e VERIFY_KEY_DIR=/data/caddy/keys \
    caddy-api /usr/bin/caddy run -c /etc/caddy/Caddyfile

rm -r data
