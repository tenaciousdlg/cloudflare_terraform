resource "cloudflare_page_rule" "lb_rule" {
  priority = 5
  status   = "active"
  target   = "lb.txflare.cf/*"
  zone_id  = "dc25a72bde0e69be65fa3b4b7b21ce85"
  actions {
    ssl = "flexible"
  }
}

resource "cloudflare_page_rule" "terraform_managed_resource_96a28f4b4f50ae10103f24188e93a64b" {
  priority = 4
  status   = "active"
  target   = "www.txflare.cf/*"
  zone_id  = "dc25a72bde0e69be65fa3b4b7b21ce85"
  actions {
    always_use_https = true
  }
}

resource "cloudflare_page_rule" "terraform_managed_resource_93f04907077a22c7748519f7475fc4c7" {
  priority = 3
  status   = "active"
  target   = "aws.txflare.cf/*"
  zone_id  = "dc25a72bde0e69be65fa3b4b7b21ce85"
  actions {
    host_header_override = "us.east1.foobar.com.aws.com"
  }
}

resource "cloudflare_page_rule" "terraform_managed_resource_07ddfe42c9c0f154824ebdd3e0ef0015" {
  priority = 2
  status   = "active"
  target   = "*.txflare.cf/*"
  zone_id  = "dc25a72bde0e69be65fa3b4b7b21ce85"
  actions {
    browser_check = "off"
    disable_apps  = true
    disable_zaraz = true
  }
}

resource "cloudflare_page_rule" "terraform_managed_resource_392588da555f3df0dacb172698905075" {
  priority = 1
  status   = "active"
  target   = "*"
  zone_id  = "dc25a72bde0e69be65fa3b4b7b21ce85"
  actions {
    cache_level = "bypass"
  }
}

