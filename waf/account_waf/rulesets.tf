# Resource that creates the filter that is deployed in the cloudflare_ruleset.acct_crawler_entrypoint resource
resource "cloudflare_ruleset" "acct_crawler_ruleset" {
    # account_id tells Terraform which Cloudflare account to run on
    account_id  = var.cloudflare_account_id
    # names the filter
    name        = "empty crawlers on robots.txt"
    # provides a description of the filter
    description = "blocks requests to robots.txt URI if UA is blank"
    # uses the custom kind as we are writing a custom waf rule. For more information on kinds and phases please refer to the Cloudflare Developer Docs
    kind        = "custom"
    # defines the phase for the filter
    phase       = "http_request_firewall_custom"

    rules {
        # defines the action Cloudflare's edge should take if the rule is matched
        action     = "block"
        # HTTP expression to match on
        expression = "(http.user_agent eq \"\" and http.request.uri contains \"/robots.txt\")" 
        # filter state
        enabled    = true
    }
}

# provides a resource to execute the cloudflare_ruleset.acct_crawler_ruleset resource
resource "cloudflare_ruleset" "acct_crawler_entrypoint" {
    account_id  = var.cloudflare_account_id
    name        = "Account level entry point for the acct_crawler_ruleset"
    description = ""
    # an account level kind is known as root
    kind        = "root"
    # defines the phase to run the resource on 
    phase       = "http_request_firewall_custom"
    # creates a Terraform depency on the filter resource
    depends_on = [
      cloudflare_ruleset.acct_crawler_ruleset
    ]

    rules {
      # defines the state of the execution 
      action = "execute"
      action_parameters {
        # pulls the ID of the listed resource
        id = cloudflare_ruleset.acct_crawler_ruleset.id
      }
      # runs this on every enterprise zone in the account (required for account level WAF)
      expression = "(cf.zone.plan eq \"ENT\")"
      description = ""
      enabled    = true
    }
}

# creates an account level managed WAF resource
resource "cloudflare_ruleset" "acct_exposed_creds_ruleset" {
    account_id  = var.cloudflare_account_id
    name        = "acct WAF exposed creds ruleset"
    description = "acct WAF exposed creds ruleset"
    # account level kind
    kind        = "root"
    # the managed phase is used here due to a managed ruleset being involved
    phase       = "http_request_firewall_managed"

    rules {
        action     = "execute"
        action_parameters {
          # UUID of the exposed credentials ruleset. See zone_waf repository for example of custom script to avoid hardcoding UUID
          id       = "c2e184081120413c86c3ab7e14069605"
          version  = "latest" 
        }
        # match criteria for resource
        expression = "((http.host contains \"cloudflarerocks.net\")) and (cf.zone.plan eq \"ENT\")"
        description = "Executes the exposed creds managed ruleset on any hostname containing cloudflarerocks.net"
        enabled    = true
    }
}