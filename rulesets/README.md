# Applying WAF Rulesets to a Cloudflare Zone via Terraform

## Pre-requisites 

An important thing to know at the beginning of this is that if you're going to use Terraform to manage the new WAF, you must only use Terraform. If you've already created a ruleset (toggled on the new WAF) in the dashboard, you must delete that ruleset first so that it can then be created with Terraform. That needs to be done via the API with two calls.

1. First list any created (aka non-managed) rulesets.

> I have exported variables in the below call. 

```
zone_id=XXXXXXXXXX
user=dlg@example.com
token=XXXXXXXXXX

curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone"))'

```

2. Use jq t filter to just the "id" fields on the rulesets listed from step 1. If nothing lists you can move onto the next section

```
curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone")) | .id'
```

3. The results from step 2 can then be fed into the DELETE call to remove the rulesets ahead of creating them in Terraform

* WARNING: THIS WILL DELETE ANY EXISTING RULESETS IN YOUR CLOUDFLARE ZONE!!!"

```
for id in $(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq -r '.result[] | select(.kind | contains("zone")) | .id'); do curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets/$id" \
     -H "X-Auth-Email: $user" \
     -H "X-Auth-Key: $token" \
     -H "Content-Type: application/json" | jq; done
```

## How to use this repository 

1. Copy ../terraform.tfvars.example to the current directory

```
> pwd
~/cloudflare_terraform/rulesets

> 
cp -via ~/cloudflare_terraform/terraform.tfvars.example rulesets/terraform.tfvars 
```

2. Populate `terraform.tfvars` with values applicable to you.

3. Run a `terraform plan` to see what the configuration will do

It will setup an exclusion for Cloudflare Managed Ruleset at the zone level
It will execute the Cloudflare Managed Ruleset at the zone level
It will execute the OWASP Cloudflare Ruleset at the zone level with Paranoia Level 1 and Anomaly Score >60

4. Run `terraform apply`

5. Make changes as needed and re-run steps 3 and 4. If you need to remove the configration 
