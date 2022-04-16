# The random_id resource is used to generate a 35 character secret for the tunnel
resource "random_id" "tunnel_secrets" {
    for_each = var.instances
    byte_length = 35
}

# A Named Tunnel resource called zero_trust_ssh_http
resource "cloudflare_argo_tunnel" "warp_tunnels" {
    for_each   = var.instances
    account_id = var.cloudflare_account_id
    name       = "${each.key}_zt" 
    secret     = random_id.tunnel_secrets[each.key].b64_std
}