#!/usr/bin/env bash
set -euo pipefail

_build_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _build_script_dir

. "$_build_script_dir/lib/logging.sh"


if [ -z "$CONTEXT" ]; then
    error "build.sh: CONTEXT env var not set"
    exit 2
fi

info "Building '$CONTEXT' context..."
export CONTEXT

case $CONTEXT in
    lab)
        just provision
        just configure
        just deploy
        ;;
    *)
        error "build: unknown context: $CONTEXT"
        exit 1
        ;;
esac
