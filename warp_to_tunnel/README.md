# [Warp to Tunnel](https://developers.cloudflare.com/cloudflare-one/tutorials/warp-to-tunnel/) running on GCP

This Terraform demo demonstrates how to spin up a [remote desktop](https://remotedesktop.google.com/access/) in Google Cloud (GCP) with [WARP](https://developers.cloudflare.com/warp-client/get-started/linux/) installed. 

Seperate instances are created in geographically different zones in GCP that live on different 10.0.0.0/8 IP space from the remote desktop. The remote instances have their 10.x.x.x/32 IP range proxied via a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/) to the Cloudflare Account that WARP running on the desktop is affiliated with.

The remote desktop is able to reach applications on the 10.x.x.x/32 range on the instances via the WARP client to the remote Tunnels. 

## Terraform Resources

* [Cloudflare Argo Tunnel](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/argo_tunnel)

* [Google Compute Instance Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

* [Google Compute Image Data Source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)

* [Null Resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)

* [Rnadom ID](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)

## Workstation Pre-requisites

On the device running this Terraform demo the following needs to be installed.

### cloudflared

Instructions on how to install cloudflared can be found [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/).

Once installed run the command `cloudflared tunnel login`. 

Following the prompts will affiliate cloudflared with your account. One of the files downloaded is a cert.pem file located at `~/.cloudflared/cert.pem`. 

In order to route private networks cloudflared needs the cert.pem file. The Terraform config looks for this file at `~/.cloudflared/cert.pem`. 

### gcloud-cli

Instructions on how to install and configure gcloud can be found [here](https://cloud.google.com/sdk/docs/install-sdk).

### Terraform

Insturctions on how to download Terrafrom can be found [here](https://www.terraform.io/downloads).

This demo was tested using the 1.x version of Terraform.

```
❯ terraform --version
Terraform v1.1.8
on darwin_arm64
+ provider registry.terraform.io/cloudflare/cloudflare v3.12.2
+ provider registry.terraform.io/hashicorp/google v4.17.0
+ provider registry.terraform.io/hashicorp/random v3.1.2
```

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

* README.md

* desktop.tf

* main.tf

* private_instances.tf

* scripts/*

* terraform.tfvars

* tunnels.tf

* variables.tf

## Usage

1. Copy the `terraform.tfvars.example` file from the `cloudflare_terraform` directory to this one as `terraform.tfvars`.

```
❯ cp -via ../terraform.tfvars.example terraform.tfvars
../terraform.tfvars.example -> terraform.tfvars
```

2. Review the `terraform.tfvars` file and update the variables as necessary.

3. Initialize the Terraform configuration by running `terraform init`. 

```
❯ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of cloudflare/cloudflare from the dependency lock file
- Reusing previous version of hashicorp/google from the dependency lock file
- Reusing previous version of hashicorp/null from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Using previously-installed cloudflare/cloudflare v3.12.2
- Using previously-installed hashicorp/google v4.17.0
- Using previously-installed hashicorp/null v3.1.1
- Using previously-installed hashicorp/random v3.1.2
- Using previously-installed hashicorp/local v2.2.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

The `terraform init` command only needs to be run on initial usage and provider/resource updates.

4. Test the deployment by running `terraform plan`. You will be asked to provide three inputs for variables. The `--out=name.plan` flag can be added to write the plan to a file.

The `chrome_remote_desktop` variable is sourced from [this resource](https://remotedesktop.google.com/headless). You will want to click on Begin > Next > Authorize > then the Copy (two boxes) icon next to the string that starts with `DISPLAY`. When you paste it into your plan it should look like the following.

```
❯ terraform plan --out=demo.plan
var.chrome_remote_desktop
  The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here.

  Enter a value: DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="[redacted]" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)

var.pin
  Please type 6 digits to use as a login pin with Chrome Remote Desktop.
  e.g. 123456

  Enter a value: 123456

var.user
  Your GCP user. Typically the same as your workstation user.
  If you're not sure run 'env | grep '^USER' and use that value.

  Enter a value: dlg

random_id.origin_name: Refreshing state... [id=7G0]
random_id.tunnel_secrets["emea"]: Refreshing state... [id=biaNOFuH2b5IYjPCCA7YyqgRV8gmcbJ-6tBPPerDKoEc3qE]
...
Saved the plan to: demo.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "demo.plan"
```

5. If everything looks correct run `terraform apply` and accept the prompts after review. The command `terraform apply "name.plan"` can also be used if the `--out=name.plan` flag was used on step 4. 

6. When done run `terraform destroy` to remove the configuration. You can provide blank inputs for the variables at this point. 

```
❯ terraform destroy
var.chrome_remote_desktop
  The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here.

  Enter a value: 

var.pin
  Please type 6 digits to use as a login pin with Chrome Remote Desktop.
  e.g. 123456

  Enter a value: 

var.user
  Your GCP user. Typically the same as your workstation user.
  If you're not sure run 'env | grep '^USER' and use that value.

  Enter a value: 

random_id.origin_name: Refreshing state... [id=7G0]
random_id.namespace: Refreshing state... [id=E5M]
...
```

Each time you run this you will need to go to [the Chrome Remote Desktop](https://remotedesktop.google.com/headless) interface and get a new token for the `var.chrome_remote_desktop` variable. This will start with `DISPLAY`.