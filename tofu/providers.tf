provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  api_token = "${var.proxmox_user}@pam!${var.proxmox_token_id}=${var.proxmox_token_secret}"

  ssh {
    agent       = false
    username    = var.proxmox_user
    private_key = file(var.proxmox_ssh_private_key_path)
  }
}

provider "random" {}

provider "null" {}

provider "local" {}

provider "http" {}
