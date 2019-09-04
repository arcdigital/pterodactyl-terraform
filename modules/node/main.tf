resource "digitalocean_droplet" "nodes" {
  count              = "${var.node_count}"
  ssh_keys           = ["${var.ssh_key_fingerprint}"]
  image              = "${var.os_image}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  backups            = "${var.enable_backups}"
  ipv6               = "${var.enable_ipv6}"
  monitoring         = "${var.enable_monitoring}"
  name               = "pterodactyl-node-${count.index + 1}"

  connection {
    type    = "ssh"
    host    = "${self.ipv4_address}"
    agent   = true
    user    = "root"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/templates/wings.service"
    destination = "/etc/systemd/system/wings.service"
  }

  provisioner "file" {
    source      = "${path.module}/templates/install_daemon.sh"
    destination = "/root/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/install.sh",
      "/root/install.sh",
    ]
  }
}

resource "digitalocean_record" "nodes" {
  count  = "${var.node_count}"
  domain = "${var.root_domain}"
  type   = "A"
  name   = "node${count.index + 1}"
  value  = "${element(digitalocean_droplet.nodes.*.ipv4_address, count.index)}"
}
