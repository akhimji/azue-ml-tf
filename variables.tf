# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

variable "resource_group" {
  default = "aml-terraform-demo"
}

variable "workspace_display_name" {
  default = "aml-terraform-demo"
}

variable "location" {
  default = "East US"
}

variable "deploy_aks" {
  default = false
}

variable "jumphost_username" {
  default = "akadmin"
}

variable "jumphost_password" {
  default = "Venyon2021!!!"
}

variable "prefix" {
  type = string
  default = "aml"
}

resource "random_string" "postfix" {
  length = 6
  special = false
  upper = false
}