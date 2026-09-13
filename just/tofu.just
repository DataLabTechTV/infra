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

_tofu action context *args:
    tofu -chdir='{{tofu_dir}}' workspace select '{{context}}' || \
        tofu -chdir='{tofu_dir}}' workspace new '{{context}}'

    tofu -chdir='{{tofu_dir}}' \
        {{action}} \
        -var-file='{{config_file}}' \
        -var='context={{context}}' \
        {{args}}

# Check infrastructure changes for the specified context
plan context: _check
    @just --justfile '{{module_file()}}'  _tofu plan '{{context}}'

# Apply infrastructure changes for the specified context
apply context: _check
    @just --justfile '{{module_file()}}' _tofu apply '{{context}}'

# Destroy infrastructure the specified context
destroy context: _check
    @just --justfile '{{module_file()}}' _tofu destroy '{{context}}'

# Print generated configurations and credentials (plain text)
output context: _check
    @just --justfile '{{module_file()}}' _tofu output '{{context}}' -show-sensitive
