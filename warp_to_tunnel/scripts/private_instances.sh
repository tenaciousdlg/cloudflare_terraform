#!/bin/bash
# Instructs a shell (script) to exit if a command fails, i.e., if it outputs a non-zero (error) exit status.
set -e
# Program functions
# Updates the OS, installs packages, tells instance to use Cloudflare for DNS
function base_os() {
    sudo apt update --assume-yes
    sudo apt install --assume-yes wget resolvconf vim
    echo 'nameserver 1.1.1.1' | sudo tee -a /etc/resolvconf/resolv.conf.d/head
}
# Installs the repoistory then package for cloudflared
function cloudflared_install() {
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ focal main' | sudo tee /etc/apt/sources.list.d/cloudflare-main.list
    sudo curl https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
    sudo apt-get update --assume-yes
    sudo apt install --assume-yes cloudflared
}
# Creates the JSON file to run the cloudflared service
function cloudflared_json() {
    sudo mkdir -p /etc/cloudflared
    sudo touch /etc/cloudflared/cert.json
    sudo cat > /etc/cloudflared/cert.json << "EOF"
        {
            "AccountTag"   : "${account}",
            "TunnelID"     : "${tunnel_id}",
            "TunnelSecret" : "${secret}"
        }
EOF
}
# Creates the Ingress Rules for the cloudflared service
function cloudflared_config() {
    touch /etc/cloudflared/config.yml
    cat > /etc/cloudflared/config.yml << "EOF"
tunnel: "${tunnel_id}"
credentials-file: /etc/cloudflared/cert.json
logfile: /var/log/cloudflared.log
loglevel: info
warp-routing:
  enabled: true
EOF
}
# Creates the cloudflared cert.pem from the primary workstation. This is needed to route networks.
function cloudflared_cert() {
    sudo touch /etc/cloudflared/cert.pem
cat > /etc/cloudflared/cert.pem << "EOF"
${config_file}
EOF
}

function foo() {
    ten_ip=$(ip addr | awk '/ 10\./{print $2}')
    export ten_ip
    cloudflared tunnel route ip add $ten_ip "${tunnel_id}"
    cloudflared service install
}

function lemp_stack() {
    sudo apt install --assume-yes nginx
   # sudo apt install --assume-yes mysql-server
   # sudo apt install --assume-yes php-fpm php-mysql
   sudo systemctl start nginx
   sudo systemctl enable nginx
}

function grafana() {
    sudo apt-get install -y apt-transport-https
    sudo apt-get install -y software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install grafana
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
}

# main program
base_os
cloudflared_install
cloudflared_json
cloudflared_config
cloudflared_cert
foo
lemp_stack
grafana