proxmox_endpoint = "https://proxmox:8006"
proxmox_node     = "pve"

proxmox_user         = "terraform"
proxmox_token_id     = "dlt"
proxmox_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure     = true  # disables certificate validation

proxmox_ssh_private_key_path = "~/.ssh/proxmox"
vm_ssh_public_key_path       = "~/.ssh/vms.pub"
