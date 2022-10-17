# Cloudflare Terraform WAF Configurations

The following repository is configured into two directories. 

The `account_waf` directory focuses on the new Account level WAF and its configuration. 

The `zone_waf` directory focuses on the new Zone level WAF and its configuration.

```
❯ tree
├── account_waf  
│   ├── main.tf  <== contains provider information
│   ├── rulesets.tf  <== main configuration file, rules are created and implemented here
│   ├── terraform.tfvars <== source of input variables for Terraform
│   └── variables.tf  <== variables used in this Terraform config
└── zone_waf
    ├── README.md
    ├── main.tf  <== contains provider information
    ├── rulesets.tf  <== main configuration file, rules are created and implemented here 
    ├── scripts 
    │   ├── cf_managed_rules_id.sh  <== script used to avoid hardcoding ruleset UUID
    │   ├── cf_owasp_anomaly_rule.sh  <== script used to avoid hardcoding rule UUID
    │   └── cf_owasp_rules_id.sh  <== script used to avoid hardcoding ruleset UUID
    ├── terraform.tfvars  <== source of input variables for Terraform
    └── variables.tf  <== variables used in this Terraform config 
```

## Pre-requisites 

An important thing to know at the beginning of this tutorial is that if you're going to use Terraform to manage the new WAF you must only use Terraform. If you havve already created a ruleset (toggled on the new WAF) in the dashboard you must delete that ruleset first. Subsequent changes can then be made via Terraform. The deletion of these dashboard made rulesets needs to be done via the Cloudflare API with the following two calls.

To use this example you must have the [jq](https://stedolan.github.io/jq/) utility installed. 

The 1.x version of Terraform is used with this tutorial. 

```
❯ terraform --version
Terraform v1.3.2
on darwin_arm64
```

1. First list any created rulesets.

> Variables for user credetials are exported first then the API call is made.

```
zone_id=XXXXXXXXXX
user=dlg@example.com
token=XXXXXXXXXX

curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone"))'

```

2. Use jq to filter to just the "id" fields on the rulesets listed from step 1. If nothing lists you can move onto the next section

```
curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone")) | .id'
```

3. The results from step 2 can then be fed into the DELETE call to remove the rulesets ahead of creating them in Terraform

* WARNING: THIS WILL DELETE ANY EXISTING WAF RULESETS IN YOUR CLOUDFLARE ZONE!!!"

```
for id in $(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone")) | .id'); do curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets/$id" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq; done
```

## Using this Repository (after doing the above clean up)

> Note: Hardcoded variables in plaintext are used as part of this example. In production a secrets manager should be used. 

1. Copy `terraform.tfvars.example` to the either the account or zone directory (depending on use case) as `terraform.tfvars`.

Example: 
```
> pwd
~/cloudflare_terraform/waf

❯ cp -via ./terraform.tfvars.example zone_waf/terraform.tfvars
./terraform.tfvars.example -> zone_waf/terraform.tfvars
```

2. Populate `terraform.tfvars` with your Cloudflare credentials.

3. Run `terraform init` to initialize Terraform in the current directory.  

4. Run `terraform plan` to see what the configuration will do.

For the Account WAF


For the Zone WAF
It will setup an exclusion for Cloudflare Managed Ruleset at the zone level
It will execute the Cloudflare Managed Ruleset at the zone level
It will execute the OWASP Cloudflare Ruleset at the zone level with Paranoia Level 1 and Anomaly Score >60

5. Run `terraform apply` to enable these changes. 

6. Make changes as needed and re-run steps 3 and 4. If you need to update the configration 

## Cleaning Up
If you wish to remove the Terraform applied configurations run `terraform destroy`. Exercise caution when doing so as this will delete any existing configs within scope. 
