# resource to create/configure all account managed rulesets
resource "cloudflare_ruleset" "account_managed_waf" {
    # account_id tells Terraform which Cloudflare account to run on. As these rulesets operate at the account level we will provide it instead of the zone id
    account_id  = var.cloudflare_account_id
    name        = "account managed waf rulesets - terraform"
    description = ""
    kind        = "root"
    phase       = "http_request_firewall_managed"
    # Provisioning for Cloudflare Managed ruleset
    rules {
      action = "execute"
      action_parameters {
        id   = "efb7b8c949ac4650a09736fc376e9aee"
        overrides {
          rules {
            id     = "5de7edfa648c4d6891dc3e7f84534ffa"
            action = "js_challenge"
            status = "enabled"
          }
          action = "block"
          status = "enabled"
        }
        #matched_data {
        #  public_key = "keydata"
        #}
      }
      expression  = "((not http.host contains \"domain.com\")) and (cf.zone.plan eq \"ENT\")"
      description = "account cloudflare managed ruleset"
      enabled     = true
    }
    # Provisioning for Cloudflare OWASP Managed ruleset
    rules {
      action = "execute"
      action_parameters {
        # UUID for Cloudflare OWASP Core ruleset
        id = "4814384a9e5d4991b9815dcfc25d2f1f"
        overrides {
          rules {
            id              = "6179ae15870a4bb7b2d480d4843b323c"
            action          = "block"
            score_threshold = 25
          }
        }
        #matched_data {
        #  public_key = "keydata"
        #}
      }
      expression  = "((not http.host contains \"domain.com\")) and (cf.zone.plan eq \"ENT\")"
      description = "account cloudflare OWASP core ruleset"
      enabled     = true      
    }
    # Provisioning for Cloudflare Exposed Credentials Check ruleset
    rules {
      action = "execute"
      action_parameters {
        # UUID for Cloudflare Exposed Credentials Check ruleset
        id = "c2e184081120413c86c3ab7e14069605"
      }
      expression  = "((not http.host contains \"domain.com\")) and (cf.zone.plan eq \"ENT\")"
      description = "account cloudflare exposed credentials check ruleset"
      enabled     = true
    }
    # Skip for CF Managed ruleset
    rules {
      action = "skip"
      action_parameters {
        rulesets = ["efb7b8c949ac4650a09736fc376e9aee"]
      }
      expression  = "(cf.zone.name eq \"domain.com\" and http.request.uri.query contains \"skip=cf\") and (cf.zone.plan eq \"ENT\")"
      description = "skip cloudflare managed ruleset with criteria"
      enabled     = true
    }
    # Skip all account rulesets
    rules {
      action = "skip"
      action_parameters {
        ruleset = "current"
      }
      expression  = "(cf.zone.name eq \"domain.com\" and http.request.uri.query contains \"skip=true\") and (cf.zone.plan eq \"ENT\")"
      description = "skip all account managed rulesets with criteria"
      enabled     = true
    }
}
# resource to create/configure all account rate limit deployment filters
resource "cloudflare_ruleset" "account_rl_filter" {
    account_id  = var.cloudflare_account_id
    name        = "rate limit on uri query"
    description = ""
    kind        = "custom"
    phase       = "http_ratelimit"
    rules {
      action = "block"
      description = "rate limit on request headers"
      enabled = true
      expression  = "(http.request.uri.query contains \"ratelimit=1\")"
      action_parameters {
        response {
          content      = "{\"response\": \"block\"}"
          content_type ="application/json"
          status_code  = 429
        }
      }
      ratelimit {
        characteristics     = ["ip.src","cf.colo.id"]
        period              = 10
        requests_per_period = 2
        mitigation_timeout  = 60
      }
    }
}
# resource to create/configure all account rate limit deployments
resource "cloudflare_ruleset" "account_rl" {
    account_id  = var.cloudflare_account_id
    name        = "rate limit using user-agent and ASN filter"
    description = ""
    kind        = "root"
    phase       = "http_ratelimit"
    depends_on  = [
      cloudflare_ruleset.account_rl_filter
    ]
    rules {
      action = "execute"
      action_parameters {
        id   = cloudflare_ruleset.account_rl_filter.id
      }
      expression  = "(cf.zone.plan eq \"ENT\")"
      description = "account rate limit"
      enabled     = true
    }
}
# resource to create/configure account custom rules deployment filters
resource "cloudflare_ruleset" "challenge_openproxy" {
    account_id  = var.cloudflare_account_id
    name        = "open proxy challenge"
    description = ""
    kind        = "custom"
    phase       = "http_request_firewall_custom"
    rules {
      action = "rewrite"
      action_parameters {
        headers {
            name      = "Exposed-Credential-Check"
            operation = "set"
            value     = "1"
        }
      }
      exposed_credential_check {
        username_expression = "url_decode(http.request.body.form[\"_username\"][0])"
        password_expression = "url_decode(http.request.body.form[\"_password\"][0])"
      }
      expression  = "http.request.method == \"POST\" && any(http.request.headers[\"content-type\"][*] == \"application/x-www-form-urlencoded\") && len(http.request.body.form[\"_username\"]) > 0 && len(http.request.body.form[\"_password\"]) > 0"
      description = "exposed cred _u _p"
      enabled     = true
    }
    rules {
      action      = "managed_challenge"
      expression  = "(ip.src in $cf.open_proxies)"
      description = "block open proxies"
      enabled     = true
    }
}
# another resource to create/configure account custom rule s deployment filters
resource "cloudflare_ruleset" "block_russia" {
    account_id = var.cloudflare_account_id
    name = "block russian federation"
    description = ""
    kind = "custom"
    phase = "http_request_firewall_custom"
    rules {
      action = "block"
      description = "global rule to block all traffic from the russian federation - terraform"
      enabled = true
      expression = "(ip.geoip.country eq \"RU\")"
    }
}
# another resource to create/configure account custom rule s deployment filters
resource "cloudflare_ruleset" "block_belarus" {
    account_id = var.cloudflare_account_id
    name = "block belarus"
    description = ""
    kind = "custom"
    phase = "http_request_firewall_custom"
    rules {
      action = "block"
      description = "global rule to block all traffic from belarus - terraform"
      enabled = true
      expression = "(ip.geoip.country eq \"BY\")"
    }
}
# resource to create/configure all account custom rules deployments
resource "cloudflare_ruleset" "account_custom_rules" {
    account_id  = var.cloudflare_account_id
    name        = "account custom firewall"
    description = "deploys rulesets"
    kind        = "root"
    phase       = "http_request_firewall_custom"
    depends_on  = [
      cloudflare_ruleset.challenge_openproxy, cloudflare_ruleset.block_russia, cloudflare_ruleset.block_belarus
    ]
    rules {
      action      = "execute"
      description = "challenge managed open proxies"
      enabled     = true
      expression  = "(cf.zone.plan eq \"ENT\")"

      action_parameters {
        id = cloudflare_ruleset.challenge_openproxy.id
      }
    }
    rules {
      action      = "execute"
      description = "block belarus"
      enabled     = true
      expression  = "(cf.zone.plan eq \"ENT\")"
      action_parameters {
        id      = cloudflare_ruleset.block_belarus.id
        version = "latest"
      }
    }
    rules {
      action      = "execute"
      description = "block russian federation"
      enabled     = true
      expression  = "(cf.zone.plan eq \"ENT\")"
      action_parameters {
        id      = cloudflare_ruleset.block_russia.id
        version = "latest"
      }
    }
}