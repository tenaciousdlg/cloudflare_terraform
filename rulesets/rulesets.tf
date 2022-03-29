# Zone-level WAF Managed Ruleset
resource "cloudflare_ruleset" "zone_level_managed_waf" {
  zone_id     = var.cloudflare_zone_id
  name        = "managed WAF"
  description = "managed WAF ruleset description"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

  rules {
    action = "skip"
    action_parameters {
      rulesets = ["${data.external.cf_managed_ruleset_id.result.id}"]
    }
    expression = "(cf.zone.name eq \"domain.xyz\" and http.request.uri.query contains \"skip=rulesets\")"
    description = "Skip Cloudflare Managed rulesets"
    enabled = true
  }

  rules {
    action = "execute"
    action_parameters {
      id = "${data.external.cf_managed_ruleset_id.result.id}"
      version = "latest"
      overrides {
        categories {
          category = "wordpress"
          action   = "js_challenge"
          enabled  = true
        }
      }
    }
    expression = "true"
    description = "Execute the Cloudflare Managed Ruleset on the zone-level phase entry point ruleset"
    enabled = true
  }
}

data "external" "cf_managed_ruleset_id" {
  program = ["bash", "${path.cwd}/scripts/cf_managed_rules_id.sh"]
  query = {
    cf_user    = "${var.cloudflare_email}"
    cf_zone_id = "${var.cloudflare_zone_id}"
    cf_token   = "${var.cloudflare_token}"
  }
}