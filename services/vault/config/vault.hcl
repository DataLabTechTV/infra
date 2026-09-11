api_addr     = "http://vault.lan:8200"
cluster_addr = "http://vault.lan:8201"

ui = true

disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "file" {
  path = "/vault/data"
}
