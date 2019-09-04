output "panel-droplet-ip" {
  value = "${module.panel.panel-droplet-ip}"
}

output "panel-domain" {
  value = "${module.panel.panel-domain}"
}

output "mysql-root-password" {
  value = "${module.panel.mysql-password}"
}
output "node-domains" {
  value = "${module.nodes.node-domains}"
}