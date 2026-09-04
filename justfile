set default-list := true

mod terraform "just/terraform.just"
mod ansible "just/ansible.just"
mod service "just/service.just"

provision target:
    just terraform apply

configure target:
    just ansible configure {{target}}

deploy service:
    just service deploy {{service}}

status service:
    just service status {{service}} infra

logs service:
    just service logs {{service}} infra

restart service:
    just service restart {{service}} infra
