# Applying Multi-Region Load Balacning to a Cloudflare Zone via Terraofrm

This walkthrough demonstrates a Cloudflare Load Balancer visitable at a hostname, such as `lb.example.com`, that has three pools in geographically distinct regions in Google Cloud (GCP). The load balancer is using Random [traffic steering](https://developers.cloudflare.com/load-balancing/understand-basics/traffic-steering/). Each pool has a single instance running Contianer Optimized OS that has a [HTML container](https://hub.docker.com/r/tenaciousdlg/html-container) visitable. The HTML container echos the region that it is in. 

There are [custom rules](https://developers.cloudflare.com/load-balancing/additional-options/load-balancing-rules/create-rules/) in place on the load balancer for the three regions. The custom rule is for a cookie override. You can pass a session=region cookie where region equals either us, emea, or apac. Adding this cookie will cause all traffic to go to that particular pool. Remove 

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