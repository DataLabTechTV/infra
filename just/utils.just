set working-directory := '..'

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

# Install the root CA certificate locally and trust it
[group('local')]
trust-root-ca:
    #!/usr/bin/env bash
    set -euo pipefail
    source ./lib/logging.sh

    root_ca_crt_src_file="./local/$CONTEXT/pki/root-ca.crt"

    if [[ ! -f "$root_ca_crt_src_file" ]]; then
        error "Certificate not found: $root_ca_crt_src_file"
        exit 1
    fi

    source /etc/os-release

    root_ca_crt_dst_name="${CONTEXT}-$(basename "$root_ca_crt_src_file")"

    case "${ID_LIKE:-$ID}" in
        *fedora*)
            root_ca_crt_dst_file="/etc/pki/ca-trust/source/anchors/$root_ca_crt_dst_name"
            sudo cp "$root_ca_crt_src_file" "$root_ca_crt_dst_file"
            sudo update-ca-trust
            ;;

        *debian*|*alpine*)
            root_ca_crt_dst_file="/usr/local/share/ca-certificates/$root_ca_crt_dst_name"
            sudo cp "$root_ca_crt_src_file" "$root_ca_crt_dst_file"
            sudo update-ca-certificates
            ;;

        *arch*)
            root_ca_crt_dst_file="/etc/ca-certificates/trust-source/anchors/$root_ca_crt_dst_name"
            sudo cp "$root_ca_crt_src_file" "$root_ca_crt_dst_file"
            sudo update-ca-trust
            ;;

        *)
            error "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
