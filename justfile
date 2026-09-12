context := env("CONTEXT", "lab")
target := env("TARGET", "")

_default:
    @just _env_help
    @just --list --unsorted

_env_help:
    @echo "Environment variables:"
    @echo "    CONTEXT  Collection of infrastructure, configurations, and services (default: lab)"
    @echo "    TARGET   Limit provisioning and configuration to a specific host (unset by default)"
    @echo

# Provision, configure, and deploy all services
build:
    #!/usr/bin/env bash
    set -euo pipefail

    . ./scripts/lib/logging.sh

    case {{context}} in
        lab)
            just provision
            just configure
            just deploy openbao
            # just deploy postgres
            ;;
        *)
            error "build: unknown context: {{context}}"
            exit 1
            ;;
    esac

# Provision infrastructure (e.g., VMs)
[group('deploy')]
provision:
    just tofu apply {{context}}

# Update, upgrade, and install required packages (e.g., podman)
[group('deploy')]
configure:
    just ansible configure {{context}} {{target}}

# Deploy the specified service
[group('deploy')]
deploy service:
    just service deploy {{context}} {{target}} {{service}}

# Check systemd status for specified service
[group('manage')]
status service:
    just service status {{target}} {{service}}

# Follow systemd logs for specified service
[group('manage')]
logs service:
    just service logs {{target}} {{service}}

# Restart the specified service
[group('manage')]
restart service:
    just service restart {{target}} {{service}}

# Run OpenTofu commands directly
[group('lowlevel')]
mod tofu "just/tofu.just"

# Run Ansible commands directly
[group('lowlevel')]
mod ansible "just/ansible.just"

# Manage services directly
[group('lowlevel')]
mod service "just/service.just"
