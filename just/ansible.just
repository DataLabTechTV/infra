set working-directory := '..'

export ANSIBLE_CONFIG := './ansible/ansible.cfg'

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

# Install Ansible system dependencies
install:
    ansible-galaxy collection install -r ./ansible/requirements.yml

# Configure the infrastructure for the specified context
configure context:
    ansible-playbook \
        --inventory './ansible/inventory/{{context}}/hosts.yml' \
        './ansible/playbooks/site.yml'

# Deploy services to the specified context hosts
deploy context target="" service="":
    ansible-playbook \
        --inventory './ansible/inventory/{{context}}/hosts.yml' \
        {{ if target != '' { '--limit ' + target } else { '' } }} \
        {{ if service != '' { '--extra-vars "service=' + service + '"' } else { '' } }} \
        './ansible/playbooks/service.yml'
