set default-list := true
set working-directory := '..'

tofu_dir := absolute_path('tofu/')
config_file := join(tofu_dir, 'config.tfvars')

_check_config:
    ./scripts/tofu/check-config.sh {{config_file}}

_check_init:
    ./scripts/tofu/check-init.sh {{join(tofu_dir, '.terraform')}}

_check: _check_config _check_init

_tofu action context target="" *args:
    tofu -chdir={{tofu_dir}} workspace select {{context}} || \
        tofu -chdir={{tofu_dir}} workspace new {{context}}

    tofu -chdir={{tofu_dir}} \
        {{action}} \
        -var-file={{config_file}} \
        -var="context={{context}}" \
        {{ if target != "" { '-var="target=' + target + '"' } else { '' } }} \
        {{args}}

plan context target="": _check
    @just -f {{module_file()}}  _tofu plan {{context}} {{target}}

apply context target="": _check
    @just -f {{module_file()}} _tofu apply {{context}} {{target}}

destroy context target="": _check
    @just -f {{module_file()}} _tofu destroy {{context}} {{target}}

output context target="": _check
    @just -f {{module_file()}} _tofu output {{context}} "{{target}}" -show-sensitive
