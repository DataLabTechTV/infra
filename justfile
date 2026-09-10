context := env("CONTEXT", "lab")
target := env("TARGET", "")

# Directly call OpenTofu recipes
mod tofu "just/tofu.just"

# Directly call Ansible recipes
mod ansible "just/ansible.just"

# Directly call service management recipes
mod service "just/service.just"

_default:
    @just _env_help
    @just --list --unsorted

_env_help:
    @echo "Environment variables:"
    @echo "    CONTEXT  Collection of infrastructure, configurations, and services (default: lab)"
    @echo "    TARGET   Limit provisioning and configuration to a specific host (unset by default)"
    @echo

# Provision infrastructure (e.g., VMs)
provision:
    just tofu apply

# Update, upgrade, and install required packages (e.g., podman)
configure:
    just ansible configure {{context}} {{target}}

# Deploy the specified service
deploy service:
    just service deploy {{context}} {{target}} {{service}}

# Check systemd status for specified service
status service:
    just service status {{target}} {{service}}

# Follow systemd logs for specified service
logs service:
    just service logs {{target}} {{service}}

# Restart the specified service
restart service:
    just service restart {{target}} {{service}}
