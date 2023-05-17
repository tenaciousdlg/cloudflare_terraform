resource "cloudflare_custom_hostname_fallback_origin" "example" {
    zone_id = var.cloudflare_zone_id
    origin  = "fallback.cloudflarerocks.net"
}

resource "cloudflare_record" "fallback" {
    zone_id = var.cloudflare_zone_id
    name    = "fallback"
    type    = "CNAME"
    value   = "cloudflarerocks.net"  
    proxied = true 
}