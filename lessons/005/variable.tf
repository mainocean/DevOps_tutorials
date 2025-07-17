# Define variable for RDS password to avoid hardcoding secrets
variable "secret_key" {
  description = "The Secret Key for Django"
  type        = string
  sensitive   = true
}

variable "key_name" {
  default = "mykey"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}
