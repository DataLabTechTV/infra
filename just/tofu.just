set default-list := true
set working-directory := '..'

tofu_dir := absolute_path('tofu/')
config_file := join(tofu_dir, 'config.tfvars')

_check_config:
    ./scripts/tofu/check-config.sh {{config_file}}

_check_init:
    ./scripts/tofu/check-init.sh {{join(tofu_dir, '.terraform')}}

_check: _check_config _check_init

plan: _check
    tofu -chdir={{tofu_dir}} plan -var-file={{config_file}}

apply: _check
    tofu -chdir={{tofu_dir}} apply -var-file={{config_file}}

destroy: _check
    tofu -chdir={{tofu_dir}} destroy -var-file={{config_file}}
