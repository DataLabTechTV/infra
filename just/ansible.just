set working-directory := '..'

default_vm_ssh_key_path := "~/.ssh/vms"

export ANSIBLE_CONFIG := './ansible/ansible.cfg'
export VM_SSH_KEY_PATH := env("VM_SSH_KEY_PATH", default_vm_ssh_key_path)

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

# Install Ansible system dependencies
install:
    ansible-galaxy collection install -r ./ansible/requirements.yml

# Configure the infrastructure for the active context
configure:
    ansible-playbook \
        --inventory "./ansible/inventory/$CONTEXT/hosts.yml" \
        './ansible/playbooks/configure.yml'

# Deploy quadlets to the specified context hosts
deploy target="" quadlet="":
    ansible-playbook \
        --inventory "./ansible/inventory/$CONTEXT/hosts.yml" \
        {{ if target != '' { '--limit ' + target } else { '' } }} \
        {{ if quadlet != '' { '--extra-vars "quadlet=' + quadlet + '"' } else { '' } }} \
        './ansible/playbooks/deploy.yml'

# Test services previously deployed as quadlets
test target="" quadlet="":
    ansible-playbook \
        --inventory "./ansible/inventory/$CONTEXT/hosts.yml" \
        {{ if target != '' { '--limit ' + target } else { '' } }} \
        {{ if quadlet != '' { '--extra-vars "quadlet=' + quadlet + '"' } else { '' } }} \
        './ansible/playbooks/test.yml'
