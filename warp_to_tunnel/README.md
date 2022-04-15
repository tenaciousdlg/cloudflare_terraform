# WORK IN PROGRESS

# Creating a Remote Desktop in GCP with Cloudflare WARP installed and configured to reach private instances via Cloudflare Tunnel

This walkthrough demonstrates how to spin up a remote desktop in Google Cloud. The remote desktop has warp-cli installed. Seperate instances are created in geographically different zones in GCP that live on different 10.0.0.0/8 IP space. The remote instances have their 10.x.x.x/32 IP range securely exposed to the Cloudflare Account that WARP running on the desktop is affiliated with.

The desktop is able to reach applications on the remote instances via the WARP client talking to the remote Tunnels. 

## Terraform Resources


## Pre-requisites

I am using the 1.x version of Terraform.

```
❯ terraform --version
Terraform v1.1.8
on darwin_arm64
+ provider registry.terraform.io/cloudflare/cloudflare v3.12.2
+ provider registry.terraform.io/hashicorp/google v4.17.0
+ provider registry.terraform.io/hashicorp/random v3.1.2
```

Make sure `gcloud` is setup and authenticated to your project. Google has instructions on how to do so [here](https://cloud.google.com/sdk/docs/install-sdk).

The `chrome_remote_desktop` variable is sourced from (this resource)[https://remotedesktop.google.com/headless]. You will want to click on Begin > Next > Authorize > then the Copy (two boxes) icon next to the string that starts with `DISPLAY`. When you paste it into your plan it should look like the following.

```
❯ terraform plan --out=demo.plan
var.chrome_remote_desktop
  The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here.

  Enter a value: DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="[redacted]" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)

var.pin
```

## Heirarchy 

```
❯ pwd; tree .
~/cloudflare_terraform/warp_to_tunnel
.
├── README.md
├── desktop.tf
├── main.tf
├── scripts
│   └── desktop_script.sh
├── terraform.tfvars
└── variables.tf

1 directory, 6 files
```

## Usage

