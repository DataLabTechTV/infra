locals {
  vms = try(local.contexts[var.context].vms, {})
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
