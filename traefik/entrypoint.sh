#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- traefik "$@"
fi

# if our command is a valid Traefik subcommand, let's invoke it through Traefik instead
# (this allows for "docker run traefik version", etc)
if traefik "$1" --help | grep -s -q "help"; then
    set -- traefik "$@"
fi

if [ ! -e "/etc/ssl/certs/traefik.cert.pem" ]; then
    SUBJECT="/C=FR/ST=Calvados/L=Caen/O=Project SAS/OU=IT/CN=traefik-dashboard.${TRAEFIK_DOMAIN}"

    echo "Generate key..."
    openssl genrsa -out /etc/ssl/private/traefik.key.pem 2048
    chmod 444 /etc/ssl/private/traefik.key.pem

    echo "Generate autosigned certificate..."
    openssl req -x509 -key /etc/ssl/private/traefik.key.pem -days 375 -new -sha256 -out /etc/ssl/certs/traefik.cert.pem -subj "${SUBJECT}"
    echo "OK"
fi;

exec "$@"
