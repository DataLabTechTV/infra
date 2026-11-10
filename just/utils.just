set working-directory := '..'

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

# Install the root CA certificate locally and trust it
[group('local')]
trust-root-ca:
    #!/usr/bin/env bash
    set -euo pipefail
    source ./lib/logging.sh

    root_ca_crt_src_file="./output/$CONTEXT/pki/root-ca.crt"

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

# Benchmark models for a llama-server endpoint
[group('benchmark')]
benchmark-models endpoint_url n='5':
    #!/usr/bin/env bash
    set -euo pipefail
    source ./lib/logging.sh

    # prompt='Analyze the trade-offs of an AI workflow with and without an AI gateway and router.'
    prompt='Explain quantum computing.'
    models=( "$(curl -s {{endpoint_url}}/v1/models | jq -r '.data[].id')" )

    info "Models @ {{endpoint_url}}: ${models[*]}"
    info "Prompt: $prompt"

    if [ "${#models}" -eq 0 ]; then
        warn "No models found."
    fi

    for model in $models; do
        info "Querying (x{{n}}): $model"

        avg_tok_s=0

        for i in $(seq {{n}}); do
            tok_s="$(curl -s {{endpoint_url}}/v1/chat/completions \
                -H 'Content-Type: application/json' \
                -d '{
                    "model": "$model",
                    "messages": [
                        {
                            "role": "user",
                            "content": "$prompt"
                        }
                    ]
                }' |
            jq -r .timings.predicted_per_second)"

            avg_tok_s="$(bc <<< "scale=16; $avg_tok_s + $tok_s")"
            echo -n '.'
        done

        avg_tok_s="$(bc <<< "scale=16; $avg_tok_s / {{n}}")"
        echo

        info "Avg. tok/s: $avg_tok_s"
    done
