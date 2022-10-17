resource "cloudflare_ruleset" "acct_crawler_ruleset" {
    account_id  = var.cloudflare_account_id
    name        = "empty crawlers on robots.txt"
    description = "blocks requests to robots.txt URI if UA is blank"
    kind        = "custom"
    phase       = "http_request_firewall_custom"

    rules {
        action     = "block"
        expression = "(http.user_agent eq \"\" and http.request.uri contains \"/robots.txt\")" 
        enabled    = true
    }
}

resource "cloudflare_ruleset" "acct_crawler_entrypoint" {
    account_id  = var.cloudflare_account_id
    name        = "Account level entry point for the acct_crawler_ruleset"
    description = ""
    kind        = "root"
    phase       = "http_request_firewall_custom"

    depends_on = [
      cloudflare_ruleset.acct_crawler_ruleset
    ]

    rules {
      action = "execute"
      action_parameters {
        id = cloudflare_ruleset.acct_crawler_ruleset.id
      }
      expression = "(cf.zone.plan eq \"ENT\")"
      description = ""
      enabled    = true
    }
}