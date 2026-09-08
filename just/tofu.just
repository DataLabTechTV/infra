set default-list := true

tofu_dir := '../tofu'
config_file := join(tofu_dir, 'config.tfvars')

_check_config:
    #!/usr/bin/env bash
    . ../lib/logging.sh

    if [ ! -f {{config_file}} ]; then
        error "Configuration file not found: {{absolute_path(config_file)}}"
        exit 1
    fi

_check_init:
    #!/usr/bin/env bash
    . ../lib/prompt.sh

    if [ ! -d {{join(tofu_dir, '.terraform')}} ]; then
        while true; do
            prompt "OpenTofu is not initialized. Initialize? [yN]" ans

            case "$ans" in
                y|Y)
                    tofu -chdir={{tofu_dir}} init
                    break
                    ;;
                *)
                    exit 1
                    ;;
            esac
        done
    fi

_check: _check_config _check_init

plan: _check
    tofu -chdir={{tofu_dir}} plan -var-file={{config_file}}

apply: _check
    tofu -chdir={{tofu_dir}} apply -var-file={{config_file}}

destroy: _check
    tofu -chdir={{tofu_dir}} destroy -var-file={{config_file}}
