#!/usr/bin/env bash

docker build -t caddy-api .

mkdir -p data/caddy/{locks,rate_limit/instances}

docker run --rm -it \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
    -v $(pwd)/apikeys:/etc/caddy/apikeys \
    caddy-api /usr/bin/caddy fmt --overwrite /etc/caddy/Caddyfile

docker network create testcaddy

docker run --rm -it \
    --name testcaddy \
    --network testcaddy \
    --network-alias testcaddy \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
    -v $(pwd)/apikeys:/etc/caddy/apikeys \
    -p 8080:8080 \
    -v $(pwd)/data:/data \
    caddy-api /usr/bin/caddy run -c /etc/caddy/Caddyfile

docker network rm testcaddy

rm -r data
