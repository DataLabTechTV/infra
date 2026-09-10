output "vm_passwords" {
  value = {
    for name, password in random_password.vm :
    name => password.result
  }
  sensitive = true
}
