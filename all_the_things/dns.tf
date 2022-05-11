# DNS Records
resource "cloudflare_record" "apex" {
    zone_id = var.cloudflare_zone_id
    name    = var.cloudflare_zone
    value   = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "api" {
    zone_id = var.cloudflare_zone_id
    name    = "api"
    value   = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "httpbin" {
    zone_id = var.cloudflare_zone_id
    name    = "httpbin"
    value   = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "internal" {
    zone_id = var.cloudflare_zone_id
    name    = "internal"
    value   = "10.0.0.1"
    type    = "A"
}

resource "cloudflare_record" "wild" {
    zone_id = var.cloudflare_zone_id
    name    = "*"
    value   = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "wordpress" {
    zone_id = var.cloudflare_zone_id
    name    = "wordpress"
    value   = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}