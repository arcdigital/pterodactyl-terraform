resource "digitalocean_droplet" "panel" {
  ssh_keys           = ["${var.ssh_key_fingerprint}"]
  image              = "${var.os_image}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  backups            = "${var.enable_backups}"
  ipv6               = "${var.enable_ipv6}"
  monitoring         = "${var.enable_monitoring}"
  name               = "pterodactyl-panel"

  connection {
    type    = "ssh"
    host    = "${self.ipv4_address}"
    agent   = true
    user    = "root"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/templates/pteroq.service"
    destination = "/etc/systemd/system/pteroq.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/nginx.conf.tpl", {
      panel_domain = "cp.${var.root_domain}"
    })
    destination = "/root/nginx.conf"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/install_panel.sh.tpl", {
      panel_url       = "${var.enable_ssl == true ? "https://cp.${var.root_domain}" : "http://cp.${var.root_domain}"}"
      author_email    = "${var.author_email}"
      from_email      = "${var.from_email}"
      from_name       = "${var.from_name}"
      admin_email     = "${var.admin_email}"
      admin_username  = "${var.admin_username}"
      smtp_host       = "${var.smtp_host}"
      smtp_port       = "${var.smtp_port}"
      smtp_encryption = "${var.smtp_encryption}"
      smtp_user       = "${var.smtp_user}"
      smtp_pass       = "${var.smtp_pass}"
      mysql_password  = "${random_password.mysql-password.result}"
    })
    destination = "/root/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/install.sh",
      "/root/install.sh",
    ]
  }
}

resource "digitalocean_record" "panel" {
  domain = "${var.root_domain}"
  type   = "A"
  name   = "cp"
  value  = "${digitalocean_droplet.panel.ipv4_address}"
}

resource "random_password" "mysql-password" {
  length           = 16
  special          = true
  override_special = "/@\" "
}
