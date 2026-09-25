set working-directory := '..'

user := "rocky"

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

# Check systemd status for specified service in the given target host
status target service:
    ssh '{{user}}@{{target}}' systemctl status '{{service}}.service'

# Follow systemd logs for specified service in the given target host
logs target service:
    ssh '{{user}}@{{target}}' journalctl \
        --unit='{{service}}.service' \
        --since=yesterday \
        --lines=1000 \
        --follow

# Restart the specified service in the given target host
restart target service:
    ssh '{{user}}@{{target}}' sudo systemctl restart '{{service}}.service'
