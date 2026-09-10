set default-list := true

deploy context target service:
    ansible-playbook \
        -i hosts/{{context}}/hosts.yml \
        ansible/playbooks/service.yml \
        --limit {{target}} \
        -e service={{service}}

status target service:
    ssh {{target}} systemctl status {{service}}.service

logs target service:
    ssh {{target}} journalctl -u {{service}}.service -f

restart target service:
    ssh {{target}} systemctl restart {{service}}.service
