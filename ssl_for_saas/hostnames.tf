resource "cloudflare_custom_hostname" "example" {
    zone_id  = var.cloudflare_zone_id
    hostname = "hostname.spookydog.tk"
    ssl {
        method = "http"
    }
}