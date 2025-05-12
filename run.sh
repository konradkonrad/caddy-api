#!/usr/bin/env bash

docker build -t caddy-api .

mkdir -p data/caddy/{keys,locks,rate_limit/instances}

openssl ecparam -genkey -name prime256v1 -noout \
  -out data/caddy/keys/sign_key.pem
openssl ec -in data/caddy/keys/sign_key.pem -pubout \
  -out data/caddy/keys/verify_key.pem

docker run --rm -it \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
    -v $(pwd)/apikeys:/etc/caddy/apikeys \
    -v $(pwd)/users:/etc/caddy/users:ro \
    caddy-api /usr/bin/caddy fmt --overwrite /etc/caddy/Caddyfile

docker network create testcaddy

docker run --rm -it \
    --name testcaddy \
    --network testcaddy \
    --network-alias testcaddy \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v $(pwd)/apikeys:/etc/caddy/apikeys:ro \
    -v $(pwd)/users:/etc/caddy/users:ro \
    -p 8080:8080 \
    -v $(pwd)/data:/data \
    -e VERIFY_KEY_DIR=/data/caddy/keys \
    caddy-api /usr/bin/caddy run -c /etc/caddy/Caddyfile

docker network rm testcaddy

rm -r data
