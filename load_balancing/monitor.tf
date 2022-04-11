resource "cloudflare_load_balancer_monitor" "http_monitor" {
  type = "http"
  expected_codes = "2xx"
  method = "GET"
  timeout = 10
  path = "/health"
  interval = 75
  retries = 3
  description = "terraform example http load balancer monitor"
  probe_zone = var.cloudflare_zone
}