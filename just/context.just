set working-directory := '..'

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

_ensure_state_dir:
    mkdir -p "$STATE_DIR"

# Set context for provision, configuration, and deployment
switch name: _ensure_state_dir
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"

    echo "{{name}}" >>"$CONTEXT_STATE_FILE"
    info "Context switched to '{{name}}'"

# Unset context for provision, configuration, and deployment (defaults to 'lab')
clear:
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"

    rm -f "$CONTEXT_STATE_FILE"
    info "Context cleared"

# Show the currently active context
show:
    @echo "{{CYAN}}Context:{{NORMAL}} $CONTEXT"
