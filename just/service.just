set default-list := true

deploy host service:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/service.yml \
        --limit {{host}} \
        -e service={{service}}

status host service:
    ssh {{host}} systemctl status {{service}}.service

logs host service:
    ssh {{host}} journalctl -u {{service}}.service -f

restart host service:
    ssh {{host}} systemctl restart {{service}}.service
