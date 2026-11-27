locals {
  vms = try(local.contexts[var.context].vms, {})

  vm_os = {
    filename = "Rocky-10-GenericCloud-Base-10.3-20261112.0.x86_64.qcow2"
    url = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base-10.3-20261112.0.x86_64.qcow2"
    sha256 = "68eae06d402c8b19e7dca06e85bdc43a3476089afa3ee20d93d0d43cf9871e9e"
  }
}

resource "random_password" "vm" {
  for_each = local.vms
  length  = 20
  special = false
}

resource "random_string" "vm_salt" {
  for_each = local.vms
  length   = 16
  special  = false
}

data "external" "hashed_passwd" {
  for_each = local.vms

  program = [
    "bash",
    "-c",
    <<-EOT
      input=$(cat)
      password=$(jq -r '.password' <<< "$input")
      salt=$(jq -r '.salt' <<< "$input")
      hash=$(openssl passwd -6 -salt "$salt" -stdin <<< "$password")
      jq -n --arg hash "$hash" '{"hash": $hash}'
    EOT
  ]

  query = {
    password = random_password.vm[each.key].result
    salt     = random_string.vm_salt[each.key].result
  }
}
