ui = true
cluster_addr = "http://vault.lan:8201"
api_addr     = "http://vault.lan:8200"

storage "file" {
  path = "/openbao/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}
