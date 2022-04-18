# [Warp to Tunnel](https://developers.cloudflare.com/cloudflare-one/tutorials/warp-to-tunnel/) running on GCP

This demo demonstrates how to spin up a [remote desktop](https://remotedesktop.google.com/access/) in Google Cloud (GCP) with [WARP](https://developers.cloudflare.com/warp-client/get-started/linux/) installed. 

Seperate instances are created in geographically different zones in GCP that live on different 10.0.0.0/8 IP space from the remote desktop. The remote instances have their 10.x.x.x/32 IP range proxied via a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/) to the Cloudflare Account that WARP running on the desktop is affiliated with.

The remote desktop is able to reach applications on the 10.x.x.x/32 range on the instances via the WARP client to the remote Tunnels. 

## Terraform Resources

* [Cloudflare Argo Tunnel](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/argo_tunnel)

* [Google Compute Instance Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

* [Google Compute Image Data Source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)

* [Null Resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)

* [Rnadom ID](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)

## Workstation Pre-requisites
On the device running this Terraform demo you need to have the following installed.

### cloudflared
In order to route private networks cloudflared needs the cert.pem file. This is typically obtained using an interactive login from the command `cloudflared tunnel login`.

Make sure to run that command first to obtain the cert.pem credential file. The Terraform config looks for this file at `~/.cloudflared/cert.pem`. 

### gcloud-cli

The `gcloud` needs to be setup and authenticated to your project. Google has instructions on how to do so [here](https://cloud.google.com/sdk/docs/install-sdk).

### Terraform

This demo was tested using the 1.x version of Terraform.

```
❯ terraform --version
Terraform v1.1.8
on darwin_arm64
+ provider registry.terraform.io/cloudflare/cloudflare v3.12.2
+ provider registry.terraform.io/hashicorp/google v4.17.0
+ provider registry.terraform.io/hashicorp/random v3.1.2
```

Insturctions on how to download can be found [here](https://www.terraform.io/downloads).

Usage information can be found below.

## Heirarchy 

```
❯ pwd; tree .
~/cloudflare_terraform/warp_to_tunnel
.
├── README.md
├── desktop.tf
├── main.tf
├── private_instances.tf
├── scripts
│   ├── desktop_script.sh
│   ├── private_destroy.sh
│   └── private_instances.sh
├── terraform.tfvars
├── tunnels.tf
└── variables.tf

1 directory, 10 files
```






## Usage

1. Copy the `terraform.tfvars.example` file from the `cloudflare_terraform` directory to this one as `terraform.tfvars`.

```
❯ cp -via ../terraform.tfvars.example terraform.tfvars
../terraform.tfvars.example -> terraform.tfvars
```

2. Add your information but make sure the `machine_type` variable is `"e2-medium"`.

3. Initialize the Terraform configuration by running `terraform init`. 

> If you add or adjust the resource/providers as part of the configuration you will need to run `terraform init --upgrade`. 

4. Test your deployment by running `terraform plan`. You will be asked to provide three inputs for variables. PLease see ## Pre-requisites for where to get this information. 


The `chrome_remote_desktop` variable is sourced from [this resource](https://remotedesktop.google.com/headless). You will want to click on Begin > Next > Authorize > then the Copy (two boxes) icon next to the string that starts with `DISPLAY`. When you paste it into your plan it should look like the following.

```
❯ terraform plan --out=demo.plan
var.chrome_remote_desktop
  The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here.

  Enter a value: DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="[redacted]" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)

var.pin
```


5. If everything looks correct run `terraform apply` and accept the prompts after review.

6. When done run `terraform destroy` to remove the configuration. You can provide blank inputs for the variables at this point. 

Each time you run this you will need to go to [the Chrome Remote Desktop](https://remotedesktop.google.com/headless) interface and get a new token for the `var.chrome_remote_desktop` variable. 