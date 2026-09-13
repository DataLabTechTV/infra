variable "context" {
  type        = string
  description = "Deployment context"
  default     = "lab"
}

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox VE endpoint URL"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Proxmox VE endpoint insecure TLS"
  default     = false
}


variable "proxmox_node" {
  type        = string
  description = "Proxmox VE node name"
  default     = "pve"
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox VE PAM user without realm"
  default     = "terraform"
}

variable "proxmox_token_id" {
  type        = string
  description = "Proxmox VE API token ID"
}

variable "proxmox_token_secret" {
  type        = string
  description = "Proxmox VE API token secret"
  sensitive   = true
}

variable "proxmox_ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key used to access Proxmox VE"
  default     = "~/.ssh/proxmox"
}

variable "vm_ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key used to access the VMs"
  default     = "~/.ssh/vms.pub"
}
