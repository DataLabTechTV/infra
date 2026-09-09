terraform {
  required_version = "~> 1.11.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.6.1"
    }

    external = {
      source = "hashicorp/external"
      version = "~> 2.4.1"
    }
  }
}
