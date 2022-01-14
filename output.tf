output "password" {
  value       = random_password.password.result
  description = "The password"
  sensitive = true
}