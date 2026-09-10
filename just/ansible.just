set working-directory := '..'

_default:
    @just _env_help
    @just --justfile {{module_file()}} --list --unsorted

# Configure the infrastructure for the specified context and target (optional)
configure context target="":
    ansible-playbook \
        --inventory ./ansible/inventory/{{context}}/hosts.yml \
        ./ansible/playbooks/site.yml \
        {{ if target !=  "" { "--limit " + target } else { "" } }}
