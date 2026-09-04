set default-list := true

bootstrap target:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/bootstrap.yml \
        --limit {{target}}

configure target:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/site.yml \
        --limit {{target}}
