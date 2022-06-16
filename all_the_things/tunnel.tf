resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_argo_tunnel" "all_the_things" {
  account_id = var.cloudflare_account_id
  name       = random_id.namespace.hex
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_virtual_network" "all_the_things" {
  account_id = var.cloudflare_account_id
  name = "vnet-for-documentation"
  comment = "New tunnel virtual network for documentation"
}