# [Warp to Tunnel](https://developers.cloudflare.com/cloudflare-one/tutorials/warp-to-tunnel/) running on GCP

This Terraform demo can be used to spin up a [remote desktop](https://remotedesktop.google.com/access/) in Google Cloud (GCP) with [WARP](https://developers.cloudflare.com/warp-client/get-started/linux/) installed. 

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
The gcloud cli on the workstation needs to have access to Google Compute (to create instances).

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

## Account Pre-requisities

A Cloudflare Zero Trust account. Instructions on how to set one up can be found [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/set-up-warp/).

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

* `README.md` - This file.

* `desktop.tf` - Configuration file for the remote desktop. This file calls the desktop script to configure the instance.

* `main.tf` - Contains the provider information for the Terraform objects. When `terraform init` is ran it'll source the information here.

* `private_instances.tf` - Configuration file for the remote instances. The cloudflared service is installed and WARP routing enabled for the private 10.x.x.x IPs. NGINX is installed at port 80 and Grafana at port 3000. This file calls the private instances script to configure the instances. 

* `scripts/*` - Collection of bash scripts used for instance configuration and to remove WARP routing during `terraform destroy`. 

* `terraform.tfvars` - Variables file for configuring Google and Cloudflare. 

* `tunnels.tf` - Configuration file for Cloudflare Tunnels (cloudflared). 

* `variables.tf` - Variables for this demo are located in this file. 

## Usage

0. This repository should be copied to the workstation that conpleted the [Workstation Pre-requisites](/cloudflare_terraform/tree/main/warp_to_tunnel#workstation-pre-requisites)

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

```
❯ terraform apply "demo.plan"
random_id.tunnel_secrets["emea"]: Creating...
random_id.tunnel_secrets["apac"]: Creating...
random_id.origin_name: Creating...
random_id.namespace: Creating...
random_id.tunnel_secrets["emea"]: Creation complete after 0s [id=aW1tvv8GCOOBQXUIpxZqVebjgfOK2SRmQZfMK3KzWllrIN4]
random_id.origin_name: Creation complete after 0s [id=BEE]
random_id.namespace: Creation complete after 0s [id=Vng]
...
```

6. Terraform will then create three instances in GCP. One for the desktop and two for the remote private resources. Two tunnels are created and configured on the remote private instances. WARP is installed on the desktop along with the Cloudflare CA Certitifcate being installed to Firefox. Users will need to finish conifuring WARP when logging into the desktop.

Navigate to [Chrome Remote Desktop](https://remotedesktop.google.com/access/) and locate the zt-desktop insance. Terraform will provide the desktop name in its output after `terraform apply`. Use the pin set earlier to complete the login.

7. Once logged in click on **Activities** in the top left hand corner.

8. In the search bar that appears in the top middle of the screen type *Terminal*.

9. Click on the **Terminal** application icon.

10. Run the following command in the **Terminal** application replacing <teamname> with your Cloudflare Zero Trust Account name.
`warp-cli --accept-tos teams-enroll <teamname>`

```
dlg@zt-desktop-5678:~$ warp-cli --accept-tos teams-enroll <teamname>
A browser window should open at the following URL:

https://<teamname>.cloudflareaccess.com/warp

If the browser fails to open, please visit the URL above directly in your browser.

```

11. This will open a window in Firefox. Follow the login method set for your Cloudflare Zero Trust account. 

12. Once logged in Firefox will prompt you to open links like this with WARP. Follow the prompts and allow WARP to open these links by clicking *Open Link*. 

13. Return to the the **Terminal** application and run `warp-cli get-organization` to verify the device's enrollment. 

```
dlg@zt-desktop-5678:~$ warp-cli get-organization
<teamname>
```

14. Connect the WARP client by running `warp-cli connect`.

```
dlg@zt-desktop-5678:~$ warp-cli connect
Success
dlg@zt-desktop-5678:~$ warp-cli status
Success
Status update: Connected
dlg@zt-desktop-5678:~$ warp-cli account
Account type: Team
Registration ID: [redacted]
...
```

15. You are now ready to connect to the private instances and test WARP. Firefox can be used to view NGINX running on port 80 and Grafana running on port 3000. 

```
❯ terraform state show 'google_compute_instance.origins["emea"]' | grep 'network_ip'
        network_ip         = "10.132.0.39"

dlg@zt-desktop-5678:~$ echo "Local IP: $(ip addr | awk '/ 10\./{print $2}')"; echo "Sending curl to remote host";curl -IL 10.132.0.39:3000
Local IP: 10.150.0.47/32
Sending curl to remote host
HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Type: text/html; charset=utf-8
Expires: -1
Location: /login
Pragma: no-cache
Set-Cookie: redirect_to=%2F; Path=/; HttpOnly; SameSite=Lax
X-Content-Type-Options: nosniff
X-Frame-Options: deny
X-Xss-Protection: 1; mode=block
Date: Mon, 18 Apr 2022 04:19:07 GMT

HTTP/1.1 200 OK
Cache-Control: no-cache
Content-Type: text/html; charset=UTF-8
Expires: -1
Pragma: no-cache
X-Content-Type-Options: nosniff
X-Frame-Options: deny
X-Xss-Protection: 1; mode=block
Date: Mon, 18 Apr 2022 04:19:07 GMT

dlg@zt-desktop-5678:~$ 
```

## Clean Up

When done run `terraform destroy` to remove the configuration. You can provide blank inputs for the variables at this point. 

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

Each time this demo is ran a new token from [Chrome Remote Desktop](https://remotedesktop.google.com/headless) interface will need to be sourced for the `var.chrome_remote_desktop` variable. This token will start with `DISPLAY`.

The GCP instances are [preemptible](https://cloud.google.com/compute/docs/instances/preemptible) and will live for 24 hours at most. 

Please reach out with any questions. 