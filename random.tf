## Create password

resource "random_password" "password" {
  length           = 12
  special          = true
  number           = true
  upper            = true
  lower            = true
  override_special = "_%@"
}

