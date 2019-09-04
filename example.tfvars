do_token           = "123456abcdef"
root_domain        = "example.org"
manage_root_domain = false
node_count         = 2

os_image                   = "ubuntu-18-04-x64"
region                     = "sfo2"
ssh_public_key_fingerprint = "12:34:56:78:90:aa:bb:cc:Dd"
panel_droplet_size         = "s-1vcpu-1gb"
node_droplet_size          = "s-2vcpu-4gb"
enable_ssl                 = false

author_email    = "test@example.org"
from_email      = "test@example.org"
from_name       = "Pterodactyl Panel"
admin_email     = "test@example.org"
admin_username  = "test"
smtp_host       = "smtp.example.org"
smtp_port       = "587"
smtp_encryption = "tls"
smtp_user       = "username"
smtp_pass       = "password"
