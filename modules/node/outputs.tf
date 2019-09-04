output "panel-node-ips" {
  value = "${digitalocean_droplet.nodes.*.ipv4_address}"
}

output "node-domains" {
  value = "${digitalocean_record.nodes.*.fqdn}"
}
