#!/usr/bin/env bash
set -euo pipefail

_check_config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _check_config_dir

. "$_check_config_dir/../lib/logging.sh"
. "$_check_config_dir/../lib/prompt.sh"

if [ "$#" -lt 1 ]; then
    echo "Usage: ${0##*/} CONFIG_FILE"
    echo
    echo "Arguments:"
    echo "  CONFIG_FILE     OpenTofu project config.tfvars file path"
    exit 2
fi

config_file="$(readlink -f "$1")"

info "Checking if config file '$config_file' exists..."

if [ ! -f "$config_file" ]; then
    error "Configuration file not found: $config_file"
    exit 1
fi
