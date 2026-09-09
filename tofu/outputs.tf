output "proxy_password" {
  value     = random_password.vm["proxy"].result
  sensitive = true
}

output "data_password" {
  value     = random_password.vm["data"].result
  sensitive = true
}

output "forge_password" {
  value     = random_password.vm["data"].result
  sensitive = true
}
