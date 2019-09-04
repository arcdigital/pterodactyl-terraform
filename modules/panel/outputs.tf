output "panel-droplet-ip" {
  value = "${digitalocean_droplet.panel.ipv4_address}"
}

output "panel-domain" {
  value = "${digitalocean_record.panel.fqdn}"
}
output "mysql-password" {
  value = "${random_password.mysql-password.result}"
}
