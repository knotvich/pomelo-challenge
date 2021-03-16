variable "prefix" {
  default = "terraform"
}

variable "virtual_network_address_space" {
  default = "10.0.0.0/16"
}

variable "virtual_network_default_subnet" {
  default = "10.0.1.0/24"
}

variable "postgresql_server_name" {
  default = "postgresql"
}

variable "postgresql_db_username" {
  default = "pqsqladmin"
}

variable "postgresql_db_password" {
  default = "FRWzRhKb}@3/|~K'Lu4z"
}

variable "postgresql_version" {
  default = "11"
}

variable "postgresql_charset" {
  default = "UTF8"
}

variable "allow_start_ip_address" {
  default = "49.228.65.194"
}

variable "allow_end_ip_address" {
  default = "49.228.65.194"
}