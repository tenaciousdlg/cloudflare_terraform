// Creates random string to use as secret with tunnel
resource "random_id" "tunnel_secret" {
    byte_length = 35  
}
// Creates Cloudflare Tunnel endpoint at Cloudflare's edge
resource "cloudflare_tunnel" "access_tf" {
  account_id = var.cloudflare_account_id
  name       = "access_tf"
  secret     = random_id.tunnel_secret.b64_std
}
// Configures the Cloudflare Tunnel
resource "cloudflare_tunnel_config" "access_tf_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.access_tf.id
  config {
    origin_request {
        no_tls_verify = true
    }
    ingress_rule {
        hostname = cloudflare_record.access.hostname
        service  = "http://localhost"
    }
    ingress_rule {
        service = "http_status:404"
    }
  }
}