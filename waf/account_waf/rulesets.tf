resource "cloudflare_ruleset" "acct_ip_geo_ruleset" {
    account_id  = var.cloudflare_account_id
    name        = "dlg test ip geo block"
    description = "dlg test ip geo block countires for security"
    kind        = "custom"
    phase       = "http_request_firewall_custom"

    rules {
        action     = "block"
        expression = "(ip.geoip.country eq \"RU\" and ip.geoip.country in {\"UA\" \"CN\"})" 
        enabled    = true
    }
}

resource "cloudflare_ruleset" "acct_ip_geo_entrypoint" {
    account_id  = var.cloudflare_account_id
    name        = "Account level entry point for the acct_ip_geo_ruleset"
    description = ""
    kind        = "root"
    phase       = "http_request_firewall_custom"

    depends_on = [
      cloudflare_ruleset.acct_ip_geo_ruleset
    ]

    rules {
      action = "execute"
      action_parameters {
        id = cloudflare_ruleset.acct_ip_geo_ruleset.id
      }
      expression = "(cf.zone.plan eq \"ENT\")"
      description = ""
      enabled    = true
    }
}