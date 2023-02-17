resource "cloudflare_record" "access" {
  zone_id = var.cloudflare_zone_id
  name    = var.application_dns
  type    = "CNAME"
  value   = "${cloudflare_tunnel.access_tf.id}.cfargotunnel.com"
  proxied = true
}