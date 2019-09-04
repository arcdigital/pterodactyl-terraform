variable "root_domain" {}
variable "ssh_key_fingerprint" {}
variable "os_image" {}

variable "region" {}
variable "size" {}
variable "enable_ipv6" {}
variable "enable_backups" {}
variable "enable_monitoring" {}

// Install Script Vars
variable "enable_ssl" {}
variable "from_email" {}
variable "from_name" {}
variable "author_email" {}
variable "admin_email" {}
variable "admin_username" {}
variable "smtp_host" {}
variable "smtp_port" {}
variable "smtp_encryption" {}
variable "smtp_user" {}
variable "smtp_pass" {}
