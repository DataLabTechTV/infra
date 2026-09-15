path "sys/mounts/*" {
  capabilities = ["read", "list"]
}

path "sys/mounts/kv" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
