set default-list := true

deploy service target:
    ansible-playbook \
        -i hosts/lab/hosts.yml \
        ansible/playbooks/service.yml \
        --limit {{target}} \
        -e service={{service}}

status service target:
    ssh {{target}} systemctl status {{service}}.service

logs service target:
    ssh {{target}} journalctl -u {{service}}.service -f

restart service target:
    ssh {{target}} systemctl restart {{service}}.service
