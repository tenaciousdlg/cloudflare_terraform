resource "cloudflare_load_balancer" "global_lb" {
  enabled          = true
  name             = var.cloudflare_lbrecord
  default_pool_ids = [cloudflare_load_balancer_pool.us.id, cloudflare_load_balancer_pool.emea.id, cloudflare_load_balancer_pool.apac.id]
  fallback_pool_id = cloudflare_load_balancer_pool.us.id
  proxied          = true
  session_affinity = "none"
  session_affinity_attributes = {
    samesite = "Auto"
    secure   = "Auto"
  }
  steering_policy = "random"
  zone_id         = var.cloudflare_zone_id
  rules {
    condition = "(any(http.request.headers[\"cookie\"][*] contains \"session=apac\"))"
    disabled  = false
    name      = "APAC HTTP Cookie"
    priority  = 0
    overrides {
      default_pools = [cloudflare_load_balancer_pool.apac.id]
    }
  }
  rules {
    condition = "(any(http.request.headers[\"cookie\"][*] contains \"session=us\"))"
    disabled  = false
    name      = "US HTTP Cookie"
    priority  = 10
    overrides {
      default_pools = [cloudflare_load_balancer_pool.us.id]
    }
  }
  rules {
    condition = "(any(http.request.headers[\"cookie\"][*] contains \"session=emea\"))"
    disabled  = false
    name      = "EMEA HTTP Cookie"
    priority  = 20
    overrides {
      default_pools = [cloudflare_load_balancer_pool.emea.id]
    }
  }
}

