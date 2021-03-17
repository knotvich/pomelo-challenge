variable "prefix" {
  default = "terraform"
}

variable "virtual_network_address_space" {
  default = "10.0.0.0/16"
}

variable "virtual_network_default_subnet" {
  default = "10.0.1.0/24"
}

variable "ssh_public_key" {
  # Value will be declare in Terraform Cloud
}

variable "ssh_private_key" {
  # Value will be declare in Terraform Cloud
}

variable "postgresql_server_name" {
  default = "postgresql"
}

variable "postgresql_db_username" {
  default = "pqsqladmin"
}

variable "postgresql_db_password" {
  default = "pqsqP@ssw0rd"
}

variable "postgresql_version" {
  default = "11"
}

variable "postgresql_charset" {
  default = "UTF8"
}

variable "postgresql_allow_start_ip_address" {
  default = "0.0.0.0"
}

variable "postgresql_allow_end_ip_address" {
  default = "255.255.255.255"
}