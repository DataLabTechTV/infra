set unstable
set lists

export STATE_DIR := home_directory() / ".local/state/dlt/infra"
export CONTEXT_STATE_FILE := STATE_DIR / "context"

export DEFAULT_CONTEXT := "lab"

export CONTEXT := if path_exists(CONTEXT_STATE_FILE) {
    trim(read(CONTEXT_STATE_FILE))
} else {
    DEFAULT_CONTEXT
}

_default:
    @just --list --unsorted

_context:
    @echo "context: $CONTEXT"

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

_host quadlet:
    #!/usr/bin/env bash
    ansible-inventory -i './ansible/inventory/{{CONTEXT}}/hosts.yml' --list |
        jq -r --arg group '{{CONTEXT}}' --arg quadlet '{{quadlet}}' '
            . as $inventory
            | $inventory[$group].hosts[]
            | select($inventory._meta.hostvars[.].quadlets | index($quadlet))
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
            error "Unknown context: $CONTEXT"
            exit 1
            ;;
    esac

# Manage active context
[group('lifecycle')]
mod context "just/context.just"

# Provision infrastructure (e.g., VMs)
[group('lifecycle')]
provision:
    just tofu apply

# Update, upgrade, and install required packages (e.g., podman)
[group('lifecycle')]
configure:
    just ansible install
    just ansible configure

# Deploy quadlets, optionally limited to a target host and/or quadlet
[group('lifecycle')]
deploy target="" quadlet="":
    just ansible deploy '{{target}}' '{{quadlet}}'

# Check systemd status for specified service
[group('manage')]
status service:
    just service status "$(just _host "{{service}}")" '{{service}}'

# Follow systemd logs for specified service
[group('manage')]
logs service:
    just service logs "$(just _host "{{service}}")" '{{service}}'

# Restart the specified service
[group('manage')]
restart service:
    just service restart "$(just _host "{{service}}")" '{{service}}'

# Display generated secrets (e.g., VMs, OpenBao)
[group('support')]
mod secrets "just/secrets.just"

# Test quadlets, optionally limited to a target host and/or quadlet
[group('support')]
test target="" quadlet="":
    just ansible test '{{target}}' '{{quadlet}}'

# Utility scripts (e.g., locally trust root CA)
[group('support')]
mod utils "just/utils.just"

# Run OpenTofu commands directly
[group('lowlevel')]
mod tofu "just/tofu.just"

# Run Ansible commands directly
[group('lowlevel')]
mod ansible "just/ansible.just"

# Manage services directly
[group('lowlevel')]
mod service "just/service.just"

# Run bootc related commands
[group('lowlevel')]
mod bootc "just/bootc.just"
