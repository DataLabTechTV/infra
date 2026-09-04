set default-list := true

plan:
    terraform -chdir=terraform/proxmox plan

apply:
    terraform -chdir=terraform/proxmox apply

destroy:
    terraform -chdir=terraform/proxmox destroy
