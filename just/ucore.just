set working-directory := '..'

default_ucore_ssh_authorized_key_path := env("HOME") / ".ssh/id_ed25519.pub"

export UCORE_SSH_AUTHORIZED_KEY_PATH := env("UCORE_SSH_AUTHORIZED_KEY_PATH", default_ucore_ssh_authorized_key_path)

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

_render_butane:
    #!/usr/bin/env bash
    set -euo pipefail
    source "./lib/logging.sh"

    mkdir -p ./output/ucore
    printf 'Password: '
    export UCORE_PASSWORD_HASH="$(podman run -it --rm quay.io/coreos/mkpasswd --method=yescrypt | tail -n1)"
    printf '\n🗝️ Password hash set.\n'

    if [ ! -r "$UCORE_SSH_AUTHORIZED_KEY_PATH" ]; then
        error "File not readable: $UCORE_SSH_AUTHORIZED_KEY_PATH"
        exit 1
    fi

    export UCORE_SSH_AUTHORIZED_KEY="$(cat "$UCORE_SSH_AUTHORIZED_KEY_PATH")"
    printf '🔑 %s added to authorized keys.\n' "$UCORE_SSH_AUTHORIZED_KEY_PATH"

    cat ucore/config.bu.tmpl | envsubst > ./output/ucore/config.bu
    printf '🎆 Butane config file rendered.\n'

_render_ignition:
    #!/usr/bin/env bash
    set -euo pipefail

    podman run --interactive --rm quay.io/coreos/butane:release \
       --pretty --strict < ./output/ucore/config.bu > ./output/ucore/config.ign
    printf '🔥 Ignition config file rendered.\n'

_serve_ignition:
    #!/usr/bin/env bash
    set -euo pipefail

    lan_ip=$(ip -o -4 route get 1.1.1.1 | awk '{print $7; exit}')
    cd ./output/ucore && python -m http.server -b $lan_ip 8000

ignite: _render_butane _render_ignition _serve_ignition
