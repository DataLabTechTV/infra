set working-directory := '..'

_default:
    @just _env_help
    @just --justfile {{module_file()}} --list --unsorted

# Deploy the specified service into the target of the given context
deploy context target service:
    #!/usr/bin/env bash
    set -euxo pipefail

    playbook="./ansible/playbooks/{{service}}.yml"
    if [ ! -f "$playbook" ]; then
        playbook="./ansible/playbooks/service.yml"
    fi

    ansible-playbook \
        --inventory ./ansible/inventory/{{context}}/hosts.yml \
        $playbook \
        --limit {{target}} \
        --extra-vars service={{service}}

# Check systemd status for specified service in the given target host
status target service:
    ssh {{target}} systemctl status {{service}}.service

# Follow systemd logs for specified service in the given target host
logs target service:
    ssh {{target}} journalctl --unit={{service}}.service --follow

# Restart the specified service in the given target host
restart target service:
    ssh {{target}} systemctl restart {{service}}.service
