// Creates random string to use as secret with tunnel
resource "random_id" "tunnel_secret" {
    byte_length = 35  
}
// Creates Cloudflare Tunnel endpoint at Cloudflare's edge
resource "cloudflare_tunnel" "access_tf" {
  account_id = var.cloudflare_account_id
  name       = "access_tf"
  secret     = random_id.tunnel_secret.b64_std
  config_src = "cloudflare"
}
// Configures the Cloudflare Tunnel
resource "cloudflare_tunnel_config" "access_tf_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.access_tf.id
  config {
    origin_request {
        bastion_mode             = false
        ca_pool                  = ""
        connect_timeout          = "30"
        disable_chunked_encoding = false
        http_host_header         = "httpbin"
        keep_alive_connections   = "100"
        keep_alive_timeout       = "30"
        no_happy_eyeballs        = false
        no_tls_verify            = false
        origin_server_name       = ""
        proxy_address            = "httpbin"
        proxy_port               = "80"
        proxy_type               = ""
        tcp_keep_alive           = "30"
        tls_timeout              = "30"
    }
    ingress_rule {
        hostname = cloudflare_record.access.hostname
        service  = "http://httpbin"
    }
    ingress_rule {
        service = "http_status:404"
    }
  }
}