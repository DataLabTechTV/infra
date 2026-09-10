set default-list := true

context := env("CONTEXT", "lab")
target := env("TARGET", "")

mod tofu "just/tofu.just"
mod ansible "just/ansible.just"
mod service "just/service.just"

provision:
    just tofu apply

configure:
    just ansible configure {{context}} {{target}}

deploy service:
    just service deploy {{context}} {{target}} {{service}}

status service:
    just service status {{target}} {{service}}

logs service:
    just service logs {{target}} {{service}}

restart service:
    just service restart {{target}} {{service}}
