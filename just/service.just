set working-directory := '..'

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

# Check systemd status for specified service in the given target host
status target service:
    ssh '{{target}}' systemctl status '{{service}}.service'

# Follow systemd logs for specified service in the given target host
logs target service:
    ssh '{{target}}' journalctl --unit='{{service}}.service' --follow

# Restart the specified service in the given target host
restart target service:
    ssh '{{target}}' systemctl restart '{{service}}.service'
