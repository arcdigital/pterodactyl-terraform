variable "do_token" {
  description = "DigitalOcean API Token"
}
variable "os_image" {
  description = "OS Image"
  default     = "ubuntu-18-04-x64"
}
variable "region" {
  description = "Region"
  default     = "sfo2"
}
variable "node_count" {
  description = "Number of nodes to create in the cluster"
  default     = 1
}
variable "root_domain" {
  description = "The root domain the panel will be available on, subdomains will automatically be created"
}
variable "manage_root_domain" {
  description = "Sets if terraform should manage creation/deletion of the root domain's zone"
  default = false
}
variable "ssh_public_key_fingerprint" {
  description = "The fingerprint of your SSH key"
}
variable "panel_droplet_size" {
  description = "The size for the panel droplet"
  default = "s-1vcpu-1gb"
}
variable "node_droplet_size" {
  description = "The size for the node droplets"
  default = "s-2vcpu-4gb"
}
variable "enable_ipv6" {
  description = "Enables IPv6 on droplets"
  default = true
}
variable "enable_panel_backups" {
  description = "Enables backups on the panel droplet"
  default = true
}
variable "enable_node_backups" {
  description = "Enables backups on all node droplets"
  default = false
}
variable "enable_monitoring" {
  description = "Enables monitoring on all droplets"
  default = true
}
variable "enable_ssl" {
  description = "Enables SSL and generates a certificate (using letsencrypt)"
  default = true
}

// Variables for Panel Installation
variable "from_email" {
  description = "The email address emails are sent from"
}
variable "from_name" {
  description = "The name emails are sent from"
}
variable "author_email" {
  description = "The email address used for custom eggs"
}
variable "admin_email" {
  description = "The email address for the first admin user (must be valid)"
}
variable "admin_username" {
  description = "The username for the first admin user (must be valid)"
}
variable "smtp_host" {
  description = "The hostname for your SMTP server"
}
variable "smtp_port" {
  description = "The port for your SMTP server"
}
variable "smtp_encryption" {
  description = "The encryption type for your SMTP server"
}
variable "smtp_user" {
  description = "The username for your SMTP server"
}
variable "smtp_pass" {
  description = "The password for your SMTP server"
}
