#!/bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}
echo "* Getting latest panel version.."
VERSION="$(get_latest_release "pterodactyl/panel")"
PANEL_RELEASE_URL="https://github.com/pterodactyl/panel/releases/download/$VERSION/panel.tar.gz"

# variables
PANEL_URL="${panel_url}"
AUTHOR_EMAIL="${author_email}"
FROM_EMAIL="${from_email}"
FROM_NAME="${from_name}"
USER_EMAIL="${admin_email}"
USER_FIRST="Panel"
USER_LAST="Admin"
USER_USERNAME="${admin_username}"
SMTP_HOST="${smtp_host}"
SMTP_PORT="${smtp_port}"
SMTP_ENCRYPTION="${smtp_encryption}"
SMTP_USER="${smtp_user}"
SMTP_PASSWORD="${smtp_pass}"
MYSQL_DB="pterodactyl"
MYSQL_USER="pterodactyl"
MYSQL_PASSWORD="${mysql_password}"
ENABLE_SSL=false

#################################
function install_dependencies {
  echo "* Installing Dependencies"
  DEBIAN_FRONTEND=noninteractive apt-get -yq install software-properties-common
  LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  add-apt-repository -y ppa:chris-lea/redis-server
  curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
  DEBIAN_FRONTEND=noninteractive apt-get update

  DEBIAN_FRONTEND=noninteractive apt-get -yq install php7.3 php7.3-cli php7.3-gd php7.3-mysql php7.3-pdo php7.3-mbstring php7.3-tokenizer php7.3-bcmath php7.3-xml php7.3-fpm php7.3-curl php7.3-zip mariadb-server nginx curl tar unzip git redis-server
  systemctl enable --now redis-server
  curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

  echo "* Dependencies installed"
}
function install_panel {
  echo "* Downloading Pterodactyl Files & Dependencies"
  mkdir -p /var/www/pterodactyl
  cd /var/www/pterodactyl

  curl -Lo panel.tar.gz $PANEL_RELEASE_URL
  tar --strip-components=1 -xzvf panel.tar.gz
  chmod -R 755 storage/* bootstrap/cache/

  cp .env.example .env
  composer install --no-dev --optimize-autoloader --prefer-dist

  php artisan key:generate --force
  echo "* Downloaded Pterodactyl Files & Dependencies"
}
function configure_database {
  echo "* Creating MySQL Database & User"
  mysql -u root -e "CREATE USER '$${MYSQL_USER}'@'127.0.0.1' IDENTIFIED BY '$${MYSQL_PASSWORD}';"
  mysql -u root -e "CREATE DATABASE $${MYSQL_DB};"
  mysql -u root -e "GRANT ALL PRIVILEGES ON $${MYSQL_DB}.* TO '$${MYSQL_USER}'@'127.0.0.1' WITH GRANT OPTION;"
  mysql -u root -e "FLUSH PRIVILEGES;"
  echo "* MySQL Database & User Created"
}
function configure_panel {
  php artisan p:environment:setup --new-salt --author="$AUTHOR_EMAIL" --url="$PANEL_URL" --timezone="America/Los_Angeles" --cache="redis" --session="redis" --queue="redis" --redis-host="127.0.0.1" --redis-pass="" --redis-port=6379 --disable-settings-ui
  php artisan p:environment:database --host="127.0.0.1" --port="3306" --database="$MYSQL_DB" --username="$MYSQL_USER" --password="$MYSQL_PASSWORD"
  php artisan p:environment:mail --driver="smtp" --email="$FROM_EMAIL" --from="$FROM_NAME" --encryption="$SMTP_ENCRYPTION" --host="$SMTP_HOST" --port="$SMTP_PORT" --username="$SMTP_USER" --password="$SMTP_PASSWORD"
  chown -R www-data:www-data *
  php artisan migrate --force --seed
  php artisan p:user:make --email="$USER_EMAIL" --username="$USER_USERNAME" --name-first="$USER_FIRST" --name-last="$USER_LAST" --no-password --admin=
  mysql -u root -e "USE $${MYSQL_DB}; UPDATE users SET root_admin=1 WHERE id=1"
  php artisan p:location:make --short=dflt --long=Default
}
function configure_cron {
  echo "* Configuring Cron"
  crontab -l | { cat; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1"; } | crontab -
  echo "* Cron Configured"
}
function configure_worker {
  echo "* Configuring Worker"
  #mv /root/pteroq.service /etc/systemd/system/pteroq.service
  systemctl enable pteroq.service
  systemctl start pteroq
  echo "* Worker Configured"
}
function configure_nginx {
  echo "* Configuring nginx .."

  if [ "$ENABLE_SSL" == true ]; then
    NGINX_FILE="nginx_ssl.conf"
  else
    NGINX_FILE="nginx.conf"
  fi

  rm -rf /etc/nginx/sites-enabled/default
  mv /root/$NGINX_FILE /etc/nginx/sites-available/pterodactyl.conf
  sudo ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
  systemctl restart nginx
  echo "* Nginx Configured"
}
function perform_install {
  echo "* Starting installation"
  DEBIAN_FRONTEND=noninteractive add-apt-repository -y universe
  DEBIAN_FRONTEND=noninteractive apt-get update -yq
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -yq
  install_dependencies
  install_panel
  configure_database
  configure_panel
  configure_cron
  configure_worker
  configure_nginx
}

# start script
echo "* Pterodactyl Panel Installation Script"
perform_install
echo "* Pterodactyl Panel Installed"
