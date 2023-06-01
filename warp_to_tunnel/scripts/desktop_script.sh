#!/bin/bash
set -e 
# updates the OS and sets Cloudflare for DNS resolution
function base_os() {
    sudo apt update --assume-yes
    sudo apt install --assume-yes wget resolvconf net-tools
    echo 'nameserver 1.1.1.1' | sudo tee -a /etc/resolvconf/resolv.conf.d/head
}
# sets up Ubuntu Gnome Desktop on the remote VM
function install_desktop() {
    sudo apt install --assume-yes ubuntu-gnome-desktop
    sudo systemctl set-default graphical.target
    wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    sudo apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb
    sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'
}
# used with Chrome Remote Desktop
function display() {
    ${CRD} --user-name="${DESKTOP_USER}" --pin="${PIN}"
}
# Installs intermediate certs for Cloudflare WARP
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
# WIP June 2023
function firefox_bookmarks() {
    mkdir -p /etc/firefox/profile
    touch /etc/firefox/profile/bookmarks.html
    cat > /etc/firefox/profile/bookmarks.html << "EOF"
<DL>
    <DT><H3>Folder Name 1</H3></DT>
    <DL>
        <DT><A HREF="https://support.mozilla.org/en-US/products/firefox">Help and Tutorials</A></DT>
        <DT><A HREF="https://support.mozilla.org/en-US/kb/customize-firefox-controls-buttons-and-toolbars">Customize Firefox</A></DT>
    </DL>

    <DT><H3>Folder Name B</H3></DT>
    <DL>
        <DT><A HREF="https://www.mozilla.org/en-US/contribute/">Get Involved</A></DT>
        <DT><A HREF="https://www.mozilla.org/en-US/about/">About Us</A></DT>
    </DL>
</DL>
EOF
}
# Installs Cloudflare WARP
function warp_install() {
    sudo curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    sudo echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -a 2>/dev/null | awk '/Codename/{print $2}') main' | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt update --assume-yes
    sudo apt install --assume-yes cloudflare-warp
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
firefox_bookmarks
warp_install
reboot