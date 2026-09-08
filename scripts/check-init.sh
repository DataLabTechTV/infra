#!/usr/bin/env bash
set -euo pipefail

_check_init_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _check_init_dir

. "$_check_init_dir/lib/logging.sh"
. "$_check_init_dir/lib/prompt.sh"

if [ "$#" -lt 1 ]; then
    echo "Usage: ${0##*/} TOFU_DIR"
    echo
    echo "Arguments:"
    echo "  TOFU_DIR    OpenTofu project directory"
    exit 2
fi

tofu_dir="$1"

info "Checking if OpenTofu directory '$tofu_dir' is initialized..."

if [ ! -d "$tofu_dir" ]; then
    while true; do
        prompt "OpenTofu is not initialized. Initialize? [yN]" ans

        case "${ans?}" in
            y|Y)
                tofu -chdir="$tofu_dir" init
                break
                ;;
            *)
                exit 1
                ;;
        esac
    done
fi
