set default-list := true

bootstrap host:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/bootstrap.yml \
        --limit {{host}}

configure host:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/site.yml \
        --limit {{host}}
