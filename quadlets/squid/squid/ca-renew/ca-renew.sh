#!/usr/bin/env bash
set -euo pipefail

ca_url="${CA_URL?:CA_URL must be set}"

provisioner="squid"

cert_file="/etc/squid/ssl/squid-ca.crt"
key_file="/etc/squid/ssl/squid-ca.key"

renewal_window="720h"  # 1 month

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tmp_cert_file="$tmpdir/squid-ca.crt"
tmp_key_file="$tmpdir/squid-ca.key"

install -d -m 0700 "$(dirname "$cert_file")"

issue_certificate() {
    echo "Issuing Squid CA certificate"

    token="$(
        step ca token \
            "Squid TLS Interception CA" \
            --ca-url "$ca_url" \
            --issuer "$provisioner" \
            --key /etc/squid/step/squid-ca.json \
            --root /etc/squid/step/root-ca.crt
    )"

    step ca certificate \
        "Squid TLS Interception CA" \
        "$tmp_cert_file" \
        "$tmp_key_file" \
        --ca-url "$ca_url" \
        --token "$token"

    chmod 0600 "$tmp_key_file"
    chmod 0644 "$tmp_cert_file"

    mv "$tmp_key_file" "$key_file"
    mv "$tmp_cert_file" "$cert_file"
}

if [ ! -f "$cert_file" ] || [ ! -f "$key_file" ]; then
    issue_certificate
    echo "Squid CA certificate created"
    exit 0
fi

if step certificate needs-renewal "$cert_file" --expires-in "$renewal_window"; then
    issue_certificate
    echo "Squid CA certificate renewed"
else
    echo "Squid CA certificate does not need renewal"
fi
