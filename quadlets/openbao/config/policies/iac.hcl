path "sys/mounts" {
  capabilities = ["read", "list"]
}

path "sys/mounts/kv" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
