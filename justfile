export CONTEXT := env("CONTEXT", "lab")

_default:
    @just _env_help
    @just --list --unsorted

_env_help:
    @echo "Environment variables:"
    @echo "    CONTEXT  Collection of infrastructure, configurations, and services (default: lab)"
    @echo

_display_table $tsv_path $header_str="":
    #!/usr/bin/env bash

    tmpfile="$(mktemp)"
    trap 'rm -f "$tmpfile"' EXIT

    cp "$tsv_path" "$tmpfile"

    if command -v crabular-cli &>/dev/null; then
        extra_args=()
        if [ -z "$header_str" ]; then
            extra_args+=( --no-header )
        else
            sed -i "1s/^/$header_str\n/" "$tmpfile"
        fi
        crabular-cli --input "$tmpfile" --format 'tsv' "${extra_args[@]}"
    else
        cat "$tmpfile"
    fi

_host service:
    #!/usr/bin/env bash
    ansible-inventory -i './ansible/inventory/{{CONTEXT}}/hosts.yml' --list |
        jq -r --arg group '{{CONTEXT}}' --arg service '{{service}}' '
            . as $inventory
            | $inventory[$group].hosts[]
            | select($inventory._meta.hostvars[.].services | index($service))
            | $inventory._meta.hostvars[.].ansible_host
        '

# Provision, configure, and deploy the context
[group('lifecycle')]
up:
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"

    info "Building '$CONTEXT' context..."

    case "$CONTEXT" in
        lab)
            just provision
            just configure
            just deploy
            ;;
        *)
            error "build: unknown context: $CONTEXT"
            exit 1
            ;;
    esac

# Provision infrastructure (e.g., VMs)
[group('lifecycle')]
provision:
    just tofu apply

# Update, upgrade, and install required packages (e.g., podman)
[group('lifecycle')]
configure:
    just ansible install
    just ansible configure

# Deploy services, optionally limited to a target host and/or service
[group('lifecycle')]
deploy target="" service="":
    just ansible deploy '{{target}}' '{{service}}'

# Check systemd status for specified service
[group('manage')]
status service:
    just service status "$(just _host "{{service}}")" '{{service}}'

# Follow systemd logs for specified service
[group('manage')]
logs target service:
    just service logs "$(just _host "{{service}}")" '{{service}}'

# Restart the specified service
[group('manage')]
restart target service:
    just service restart "$(just _host "{{service}}")" '{{service}}'

# Run OpenTofu commands directly
[group('lowlevel')]
mod tofu "just/tofu.just"

# Run Ansible commands directly
[group('lowlevel')]
mod ansible "just/ansible.just"

# Manage services directly
[group('lowlevel')]
mod service "just/service.just"

# Display generated secrets
[group('lowlevel')]
mod secrets "just/secrets.just"
