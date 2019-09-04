provider "digitalocean" {
  version = "~> 1.7"
  token   = "${var.do_token}"
}

resource "digitalocean_domain" "default" {
  count = "${var.manage_root_domain == true ? 1 : 0}"
  name  = "${var.root_domain}"
}

module "panel" {
  source              = "./modules/panel"
  root_domain         = "${var.root_domain}"
  ssh_key_fingerprint = "${var.ssh_public_key_fingerprint}"
  os_image            = "${var.os_image}"
  region              = "${var.region}"
  size                = "${var.panel_droplet_size}"
  enable_ipv6         = "${var.enable_ipv6}"
  enable_backups      = "${var.enable_panel_backups}"
  enable_monitoring   = "${var.enable_monitoring}"
  enable_ssl          = "${var.enable_ssl}"
  author_email        = "${var.author_email}"
  from_email          = "${var.from_email}"
  from_name           = "${var.from_name}"
  admin_email         = "${var.admin_email}"
  admin_username      = "${var.admin_username}"
  smtp_host           = "${var.smtp_host}"
  smtp_port           = "${var.smtp_port}"
  smtp_encryption     = "${var.smtp_encryption}"
  smtp_user           = "${var.smtp_user}"
  smtp_pass           = "${var.smtp_pass}"
}

module "nodes" {
  source              = "./modules/node"
  root_domain         = "${var.root_domain}"
  ssh_key_fingerprint = "${var.ssh_public_key_fingerprint}"
  os_image            = "${var.os_image}"
  region              = "${var.region}"
  size                = "${var.node_droplet_size}"
  enable_ipv6         = "${var.enable_ipv6}"
  enable_backups      = "${var.enable_node_backups}"
  enable_monitoring   = "${var.enable_monitoring}"
  node_count          = "${var.node_count}"
}
