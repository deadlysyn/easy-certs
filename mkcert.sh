#!/usr/bin/env bash

set -e

CONF=openssl.cnf
CERTS=certs
PASSWORD=secret

function usage() {
  printf "%s [server|user] name..." "$(basename $0)"
  exit 1
}

[[ $# -lt 2 ]] && usage
[[ "$1" != server && "$1" != user ]] && usage

if [[ ! -f "$CONF" ]]
then
  echo "Can't read OpenSSL configuration $CONF"
  exit 1
fi

if [[ ! -d "$CERTS" ]]
then
  # Setup cert directory (don't commit this)
  mkdir -p "$CERTS"
  chmod 700 "$CERTS"
  touch "${CERTS}/db.txt" "${CERTS}/index.txt"
  echo 1000 > "${CERTS}/serial"
fi


if [[ ! -f "${CERTS}/ca.key" ]]
then
  printf "\n******** CERTIFICATE AUTHORITY CONFIGURATION\n\n"

  # Generate root CA key
  openssl genrsa -aes256 \
    -passout "pass:${PASSWORD}" \
    -out "${CERTS}/ca.key" 4096
  chmod 400 "${CERTS}/ca.key"
fi

if [[ ! -f "${CERTS}/ca.cert" ]]
then
  # Generate root CA cert
  openssl req -config "$CONF" \
      -key "${CERTS}/ca.key" \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -passin "pass:${PASSWORD}" \
      -out "${CERTS}/ca.cert"
fi

EXTENSION="${1}_cert"
shift

for name in "$@"
do
  printf "\n******** CONFIGURATION FOR %s\n\n" "$name"

  # Generate client key
  openssl genrsa -out "${CERTS}/${name}.key" 2048
  chmod 400 "${CERTS}/${name}.key"

  # Generate CSR
  openssl req -config "$CONF" \
        -key "${CERTS}/${name}.key" \
        -new -sha256 -out "${CERTS}/${name}.csr"
  chmod 400 "${CERTS}/${name}.csr"

  # Generate client cert
  openssl ca -config "$CONF" \
        -extensions "${EXTENSION}" -days 375 -notext -md sha256 \
        -passin "pass:${PASSWORD}" -batch \
        -in "${CERTS}/${name}.csr" \
        -out "${CERTS}/${name}.cert"
done

