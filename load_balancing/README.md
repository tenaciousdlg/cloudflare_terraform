# Applying Multi-Region Load Balacning to a Cloudflare Zone via Terraofrm

This walkthrough demonstrates a Cloudflare Load Balancer visitable at a hostname, such as `lb.example.com`, that has three pools in geographically distinct regions in Google Cloud (GCP). The load balancer is using Random [traffic steering](https://developers.cloudflare.com/load-balancing/understand-basics/traffic-steering/). Each pool has a single instance running Contianer Optimized OS that has a [HTML container](https://hub.docker.com/r/tenaciousdlg/html-container) visitable. The HTML container echos the region that it is in. 

There are [custom rules](https://developers.cloudflare.com/load-balancing/additional-options/load-balancing-rules/create-rules/) in place on the load balancer for the three regions. The custom rule is for a cookie override. You can pass a `session=region` cookie where region equals either `us`, `emea`, or `apac`. Adding this cookie will cause all traffic to go to that particular pool. Remove the coookie to return the load balancer to the default behavior.

## Terraform Resources

[Cloudflare Load Balancer](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/load_balancer)
[Cloudflare Load Balancer Pool](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/load_balancer_pool)
[Cloudflare Load Balancer Pool Monitor](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/load_balancer_monitor)
[Google Compute Instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
[Google Compute Image Data Source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)
[Random ID](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)

## Pre-requisites

I am also using the 1.x version of Terraform. 

```
❯ terraform --version
Terraform v1.1.8
on darwin_arm64
+ provider registry.terraform.io/cloudflare/cloudflare v3.12.1
+ provider registry.terraform.io/hashicorp/google v4.16.0
+ provider registry.terraform.io/hashicorp/random v3.1.2
```

Make sure `gcloud` is setup and authenticated to your project. Google has instructions on how to do so [here](https://cloud.google.com/sdk/docs/install-sdk).

## Heirarchy 

```
❯ pwd;tree .
~/cloudflare_terraform/load_balancing
.
├── README.md
├── load_balancer.tf
├── main.tf
├── monitor.tf
├── origins.tf
├── pools.tf
├── terraform.tfvars
└── variables.tf

0 directories, 8 files
```

* `load_balancer.tf` contains the config for the Cloudflare Load Balancer. This load balancer has three pools (us, emea, apac), health checks, random traffic steering, and a session based cookie override for each pool. 

* `main.tf` contains the provider information for the Terraform objects.

* `monitor.tf` contains a HTTP load balancer monitor that is added to each pool in `pools.tf`.

* `origins.tf` contains the config for the three instances in GCP. Each instance is built in a geographically distinct region and runs a HTML container.

* `pools.tf` contains the config for the three pools referenced in `load_balancer.tf`.

* `terraform.tfvars` is the credentials/variables file for this deployment. I copy it from `../terraform.tfvars.example` and added a `cloudflare_lbrecord` variable in both the `.tfvars` file and `variables.tf` file for this deployment.

* `variables.tf` is the decleration of variables file for this deployment. 

## Usage

1. Copy the `terraform.tfvars.example` file from the `cloudflare_terraform` directory to this one as `terraform.tfvars`. 

2. Add/update a `cloudflare_lbrecord` variable in the aforementioned `terraform.tfvars` file.

3. Test your deployment by running `terraform plan`.

4. If everything looks correct run `terraform apply` and accept the prompts after review.
'
5. When done run `terraform destroy` to remove the configuration. 

* If you need to view the state after terraform apply use `terraform state list` then `terraform state show 'state.object'` to review.

```
❯ terraform state list
data.google_compute_image.image
cloudflare_load_balancer.global_lb
cloudflare_load_balancer_monitor.http_monitor
cloudflare_load_balancer_pool.apac
cloudflare_load_balancer_pool.emea
cloudflare_load_balancer_pool.us
google_compute_instance.origins["apac"]
google_compute_instance.origins["emea"]
google_compute_instance.origins["us"]
random_id.namespace
❯ terraform state show 'data.google_compute_image.image'
# data.google_compute_image.image:
data "google_compute_image" "image" {
    archive_size_bytes = 1319958912
    creation_timestamp = "2022-04-11T14:32:53.804-07:00"
    description        = "Google, Container-Optimized OS, 97-16919.29.9 LTS, Kernel: COS-5.10.107 Kubernetes: 1.23.3 Docker: 20.10.12 Family: cos-97-lts, supports Shielded VM features, supports Confidential VM features on N2D"
    disk_size_gb       = 10
    family             = "cos-97-lts"
    id                 = "projects/cos-cloud/global/images/cos-97-16919-29-9"
    image_id           = "130573481484558442"
    label_fingerprint  = "VzjrmCgbErw="
    labels             = {
        "build_number" = "16919-29-9"
        "milestone"    = "97"
    }
    licenses           = [
        "https://www.googleapis.com/compute/v1/projects/cos-cloud/global/licenses/cos-pcid",
        "https://www.googleapis.com/compute/v1/projects/cos-cloud-shielded/global/licenses/shielded-cos",
        "https://www.googleapis.com/compute/v1/projects/cos-cloud/global/licenses/cos",
    ]
    name               = "cos-97-16919-29-9"
    project            = "cos-cloud"
    self_link          = "https://www.googleapis.com/compute/v1/projects/cos-cloud/global/images/cos-97-16919-29-9"
    status             = "READY"
}
```