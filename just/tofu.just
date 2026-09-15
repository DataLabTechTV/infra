set working-directory := '..'

tofu_dir := absolute_path('tofu/')
config_file := join(tofu_dir, 'config.tfvars')

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

_check-config:
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"
    source "./lib/prompt.sh"

    info "Checking if config file '{{config_file}}' exists..."

    if [ ! -f "{{config_file}}" ]; then
        error "Configuration file not found: {{config_file}}"
        exit 1
    fi

_check-init:
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"
    source "./lib/prompt.sh"

    tofu_dir='{{join(tofu_dir, ".terraform")}}'

    info "Checking if OpenTofu directory '$tofu_dir' is initialized..."

    if [ ! -d "$tofu_dir" ]; then
        while true; do
            prompt "OpenTofu is not initialized. Initialize? [yN]" ans

            case "${ans?}" in
                y|Y)
                    tofu -chdir="$tofu_dir" init
                    break
                    ;;
                *)
                    exit 1
                    ;;
            esac
        done
    fi

_check: _check-config _check-init

_tofu action *args:
    tofu -chdir='{{tofu_dir}}' workspace select "$CONTEXT" || \
        tofu -chdir='{tofu_dir}}' workspace new "$CONTEXT"

    tofu -chdir='{{tofu_dir}}' \
        {{action}} \
        -var-file='{{config_file}}' \
        -var="context=$CONTEXT" \
        {{args}}

# Check infrastructure changes for the specified context
plan: _check
    @just --justfile '{{module_file()}}'  _tofu plan

# Apply infrastructure changes for the specified context
apply: _check
    @just --justfile '{{module_file()}}' _tofu apply

# Destroy infrastructure the specified context
destroy: _check
    @just --justfile '{{module_file()}}' _tofu destroy

# Print generated configurations and credentials (format: hcl, json)
output $fmt="hcl": _check
    #!/usr/bin/env bash

    . ./scripts/lib/logging.sh

    case "$fmt" in
        json)
            just --justfile '{{module_file()}}' _tofu output -json
            ;;

        *)
            just --justfile '{{module_file()}}' _tofu output -show-sensitive
            ;;
    esac
