set default-list := true

configure context target="":
    ansible-playbook \
        -i hosts/{{context}}/hosts.yml \
        ansible/playbooks/site.yml \
        {{ if target !=  "" { "--limit " + target } else { "" } }}
