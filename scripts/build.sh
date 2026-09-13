#!/usr/bin/env bash
set -euo pipefail

_build_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _build_script_dir

. "$_build_script_dir/lib/logging.sh"

prog="${0##?/}"

if [ "$#" -lt 1 ]; then
    echo "Usage: $prog CONTEXT"
    echo "       $prog --print-target CONTEXT SERVICE"
    echo
    echo "Arguments:"
    echo "  CONTEXT     Sets the collection of VMs to provision and services to deploy"
    echo "  SERVICE     Used alongside CONTEXT to print the target host"
    exit 2
fi

print_target() {
    context="$1"
    service="$2"

    case "$context/$service" in
        lab/openbao|lab/postgres)
            echo "data"
            ;;
        *)
            error "unknown target for '$context' context and '$service' service"
            exit 1
    esac
}

build() {
    export CONTEXT="$1"

    case $CONTEXT in
        lab)
            just provision
            just configure
            just deploy openbao
            # just deploy postgres
            ;;
        *)
            error "build: unknown context: $CONTEXT"
            exit 1
            ;;
    esac
}

case "$1" in
    --print-target)
        if [ "$#" -lt 3 ]; then
            echo "Usage: $prog --print-target CONTEXT SERVICE"
            exit 2
        fi

        context="$2"
        service="$3"
        print_target "$context" "$service"
        ;;

    -*)
        error "$prog: unknown option: $1"
        exit 2
        ;;
    *)
        context="$1"
        build "$context"
        ;;
esac

