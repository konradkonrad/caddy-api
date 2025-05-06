#!/usr/bin/env bash

mkdir -p data/caddy/rate_limit

docker run --rm -it -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro -p 8080:8080 -v data:/data caddy-api /usr/bin/caddy run -c /etc/caddy/Caddyfile

rm -r data
