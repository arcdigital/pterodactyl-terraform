#!/bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}
echo "* Getting latest daemon version.."
VERSION="$(get_latest_release "pterodactyl/daemon")"
DAEMON_RELEASE_URL="https://github.com/pterodactyl/daemon/releases/download/$VERSION/daemon.tar.gz"


function install_dependencies {
    DEBIAN_FRONTEND=noninteractive apt-get update -yq
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
    DEBIAN_FRONTEND=noninteractive apt-get -yq install tar unzip make gcc g++ python apt-transport-https ca-certificates curl software-properties-common
}

function install_docker {
    echo "* Installing Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    DEBIAN_FRONTEND=noninteractive add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    DEBIAN_FRONTEND=noninteractive apt-get update -yq
    DEBIAN_FRONTEND=noninteractive apt-get -yq install docker-ce

    systemctl start docker
    systemctl enable docker
    echo "* Docker Installed"
}

function install_nodejs {
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    DEBIAN_FRONTEND=noninteractive apt -yq install nodejs
}

function install_wings {
    echo "* Installing Pterodactyl Daemon"
    mkdir -p /srv/daemon /srv/daemon-data
    cd /srv/daemon
    curl -L $DAEMON_RELEASE_URL | tar --strip-components=1 -xzv
    npm install --only=production
    echo "* Pterodactyl Daemon Installed"
}

function enable_wings {
    echo "* Enabling Wings Service"
    systemctl daemon-reload
    systemctl enable wings
    echo "* Wings Service Enabled"
}

echo "* Pterodactyl Daemon Installation Script"
install_dependencies
install_docker
install_nodejs
install_wings
enable_wings
echo "* Pterodactyl Daemon Installed"
