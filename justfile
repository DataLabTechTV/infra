set default-list := true

host := env("HOST", "local")

mod terraform "just/terraform.just"
mod ansible "just/ansible.just"
mod service "just/service.just"

provision:
    just terraform apply

configure:
    just ansible configure {{host}}

deploy service:
    just service deploy {{host}} {{service}}

status service:
    just service status {{host}} {{service}}

logs service:
    just service logs {{host}} {{service}}

restart service:
    just service restart {{host}} {{service}}
