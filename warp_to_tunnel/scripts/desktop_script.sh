#!/bin/bash
set -e 

function base_os() {
    sudo apt update --assume-yes
    sudo apt install --assume-yes wget resolvconf
    echo 'nameserver 1.1.1.1' | sudo tee -a /etc/resolvconf/resolv.conf.d/head
}

function install_desktop() {
    sudo apt install --assume-yes ubuntu-gnome-desktop
    sudo systemctl set-default graphical.target
    wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    sudo apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb
    sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'
}

function display() {
    ${CRD} --user-name="${DESKTOP_USER}" --pin="${PIN}"
}

function install_certs() {
    wget -q https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.crt
    wget -q https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem
    sudo cp Cloudflare_CA.* /usr/local/share/ca-certificates/
    sudo update-ca-certificates
}

# https://stackoverflow.com/questions/1435000/programmatically-install-certificate-into-mozilla
function firefox_cert() {
    echo '{
        "policies": {
            "Certificates": {
                "Install": [
                    "/usr/local/share/ca-certificates/Cloudflare_CA.crt"
                ]
            }
        }
    }' >> /usr/lib/firefox/distribution/policies.json
}

function warp() {
    sudo curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    sudo echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ focal main' | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt update --assume-yes
    sudo apt install --assume-yes cloudflare-warp
    warp-cli --accept-tos register
}

function reboot() {
    sh -c sudo reboot
}

# main program
base_os
install_desktop
display
install_certs
firefox_cert
warp
reboot