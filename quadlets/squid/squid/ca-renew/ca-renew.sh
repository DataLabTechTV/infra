#!/usr/bin/env bash
set -euo pipefail

ca_url="${CA_URL?:CA_URL must be set}"

provisioner="squid"
provisioner_key="/etc/squid/step/squid.json"
root_ca_cert="/etc/squid/step/root-ca.crt"

cert="/etc/squid/ssl/squid-ca.crt.new"
key="/etc/squid/ssl/squid-ca.key.new"

renewal_window="48h"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tmp_cert="$tmpdir/squid-ca.crt.new"
tmp_key="$tmpdir/squid-ca.key.new"

install -d -m 0700 "$(dirname "$cert")"

issue_certificate() {
    echo "Issuing Squid CA certificate"

    token="$(
        step ca token \
            "Squid TLS Interception CA" \
            --ca-url "$ca_url" \
            --issuer "$provisioner" \
            --key "$provisioner_key" \
            --root "$root_ca_cert"
    )"

    step ca certificate \
        "Squid TLS Interception CA" \
        "$tmp_cert" \
        "$tmp_key" \
        --ca-url "$ca_url" \
        --token "$token" \
        --not-after "720h"

    chmod 0600 "$tmp_key"
    chmod 0644 "$tmp_cert"

    mv "$tmp_key" "$key"
    mv "$tmp_cert" "$cert"
}

if [ ! -f "$cert" ] || [ ! -f "$key" ]; then
    issue_certificate
    echo "Squid CA certificate created"
    exit 0
fi

if step certificate needs-renewal "$cert" --expires-in "$renewal_window"; then
    issue_certificate
    echo "Squid CA certificate renewed"
else
    echo "Squid CA certificate does not need renewal"
fi
