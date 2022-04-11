resource "cloudflare_load_balancer_pool" "us" {
  name = "us"
  origins {
    name    = "us-1"
    address = google_compute_instance.origins["us"].network_interface.0.access_config.0.nat_ip
    enabled = true
  }
  description     = "example load balancer pool for us origin"
  enabled         = true
  minimum_origins = 1
  monitor = cloudflare_load_balancer_monitor.http_monitor.id
  origin_steering {
    policy = "random"
  }
}

resource "cloudflare_load_balancer_pool" "emea" {
    name = "emea"
    origins {
      name    = "emea-1"
      address = google_compute_instance.origins["emea"].network_interface.0.access_config.0.nat_ip
      enabled = true
    }
    description     = "example load balancer pool for emea origin"
    enabled         = true
    minimum_origins = 1
    monitor = cloudflare_load_balancer_monitor.http_monitor.id
    origin_steering {
        policy = "random"
    }
}

resource "cloudflare_load_balancer_pool" "apac" {
    name = "apac"
    origins {
      name    = "apac-1"
      address = google_compute_instance.origins["apac"].network_interface.0.access_config.0.nat_ip
      enabled = true
    }
    description = "example load balancer pool for apac origin"
    enabled     = true
    minimum_origins = 1
    monitor = cloudflare_load_balancer_monitor.http_monitor.id
    origin_steering {
      policy = "random"
    }
}