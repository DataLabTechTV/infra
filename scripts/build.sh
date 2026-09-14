#!/usr/bin/env bash
set -euo pipefail

_build_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _build_script_dir

. "$_build_script_dir/lib/logging.sh"


if [ "$#" -lt 1 ]; then
    echo "Usage: ${0##?/} CONTEXT"
    echo
    echo "Arguments:"
    echo "  CONTEXT     Sets the collection of VMs to provision and services to deploy"
    exit 2
fi

export CONTEXT="$1"

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
