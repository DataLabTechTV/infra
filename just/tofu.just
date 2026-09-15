set working-directory := '..'

tofu_dir := absolute_path('tofu/')
config_file := join(tofu_dir, 'config.tfvars')

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

_check_config:
    ./scripts/tofu/check-config.sh '{{config_file}}'

_check_init:
    ./scripts/tofu/check-init.sh '{{join(tofu_dir, ".terraform")}}'

_check: _check_config _check_init

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
