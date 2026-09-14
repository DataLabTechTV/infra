context := env("CONTEXT", "lab")

_default:
    @just _env_help
    @just --list --unsorted

_env_help:
    @echo "Environment variables:"
    @echo "    CONTEXT  Collection of infrastructure, configurations, and services (default: lab)"
    @echo

# _host target:
#     ansible-inventory -i './ansible/inventory/{{context}}/hosts.yml' --host '{{service}}' | jq -r '.ansible_host'

# Provision, configure, and deploy all services
build:
    ./scripts/build.sh '{{context}}'

# Provision infrastructure (e.g., VMs)
[group('deploy')]
provision:
    just tofu apply '{{context}}'

# Update, upgrade, and install required packages (e.g., podman)
[group('deploy')]
configure:
    just ansible install
    just ansible configure '{{context}}'

# Deploy services to the correct hosts
[group('deploy')]
deploy:
    just ansible deploy '{{context}}'

# Check systemd status for specified service
[group('manage')]
status service:
    just service status "$(just _target "{{service}}")" '{{service}}'

# Follow systemd logs for specified service
[group('manage')]
logs target service:
    just service logs "$(just _target "{{service}}")" '{{service}}'

# Restart the specified service
[group('manage')]
restart target service:
    just service restart "$(just _target "{{service}}")" '{{service}}'

# Run OpenTofu commands directly
[group('lowlevel')]
mod tofu "just/tofu.just"

# Run Ansible commands directly
[group('lowlevel')]
mod ansible "just/ansible.just"

# Manage services directly
[group('lowlevel')]
mod service "just/service.just"
