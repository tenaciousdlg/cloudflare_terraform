# Zone-level WAF Managed Ruleset
resource "cloudflare_ruleset" "zone_level_managed_waf" {
  zone_id     = var.cloudflare_zone_id
  name        = "managed WAF"
  description = "managed WAF ruleset description"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

# Example of skipping a ruleset given pieces of criteria
# In this case the Cloudflare Managed Rulesets will be skipped if the hostname is domain.xyz and the path is skip=rulesets
  rules {
    action = "skip"
    action_parameters {
      rulesets  = ["${data.external.cf_managed_ruleset.result.id}"]
    }
    expression  = "(cf.zone.name eq \"domain.xyz\" and http.request.uri.query contains \"skip=rulesets\")"
    description = "Skip Cloudflare Managed rulesets"
    enabled     = true
  }

# Example of setting a ruleset to execute. In this case the Cloudflare Managed Ruleset
# An override is used to alter the behavior of the rules tagged with wordpress to js_challenge as their action
  rules {
    action = "execute"
    action_parameters {
      id      = "${data.external.cf_managed_ruleset.result.id}"
      version = "latest"
      overrides {
        categories {
          category = "wordpress"
          action   = "js_challenge"
          enabled  = true
        }
      }
    }
    expression  = "true"
    description = "Execute the Cloudflare Managed Ruleset on the zone-level phase entry point ruleset"
    enabled     = true
  }

# Example of setting a ruleset to execute. In this case the Cloudflare OWASP Ruleset
# This sets Anomaly Score for 60+ (low) with PL1 (PL1 is the default mode when OWASP deployed)
  rules {
    action = "execute"
    action_parameters {
      id = "${data.external.cf_owasp_ruleset.result.id}"
      overrides {
        categories {
          category = "paranoia-level-2"
          enabled  = false
        }
        categories {
          category = "paranoia-level-3"
          enabled  = false
        }
        categories {
          category = "paranoia-level-4"
          enabled  = false
        }
        rules {
          id              = "${data.external.cf_owasp_anomaly_score.result.id}"
          action          = "log"
          score_threshold = 60
        }
      }
    }
    expression   = "true"
    description  = "Execute the Cloudflare OWASP Ruleset with PL1 (PL1 is the default mode when OWASP is deployed)"  
    enabled      = true
  }
}

# Using external data source as rulesets do not currently have one to grab parameters
# for the Cloudflare Managed Ruleset. This is stored as a map we can query
data "external" "cf_managed_ruleset" {
  program = ["bash", "${path.cwd}/scripts/cf_managed_rules_id.sh"]
  # In the external data source query parameters are passed to the program as STDIN
  # Here we map terraform variables to ones the script can use
  query = {
    cf_user    = "${var.cloudflare_email}"
    cf_zone_id = "${var.cloudflare_zone_id}"
    cf_token   = "${var.cloudflare_token}"
  }
}

# Using external data source as rulesets do not currently have one to grab parameters
# for the Cloudflare OWASP Core Ruleset. This is stored as map we can query
data "external" "cf_owasp_ruleset" {
  program = ["bash", "${path.cwd}/scripts/cf_owasp_rules_id.sh"]
  # In the external data source query parameters are passed to the program as STDIN
  # Here we map terraform variables to ones the script can use
  query = {
    cf_user    = "${var.cloudflare_email}"
    cf_zone_id = "${var.cloudflare_zone_id}"
    cf_token   = "${var.cloudflare_token}"
  }
}

data "external" "cf_owasp_anomaly_score" {
  program = ["bash", "${path.cwd}/scripts/cf_owasp_anomaly_rule.sh"]
# This data source produced strings, booleans, and numbers. This script is setup differently to print only 
# one object from the array which is the string id
  query = {
    cf_user    = "${var.cloudflare_email}"
    cf_zone_id = "${var.cloudflare_zone_id}"
    cf_token   = "${var.cloudflare_token}"
  }
}