resource "cloudflare_record" "apex" {
    zone_id = var.cloudflare_zone_id
    name    = var.cloudflare_zone
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true
}

resource "cloudflare_record" "api" {
    zone_id = var.cloudflare_zone_id
    name    = "api"
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true
}


resource "cloudflare_record" "httpbin" {
    zone_id = var.cloudflare_zone_id
    name    = "httpbin"
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true
}

resource "cloudflare_record" "internal" {
    zone_id = var.cloudflare_zone_id
    name    = "internal"
    value   = "10.0.0.1"
    type    = "A"
}

resource "cloudflare_record" "nginx" {
    zone_id = var.cloudflare_zone_id
    name    = "nginx"
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true 
}

resource "cloudflare_record" "ssh" {
    zone_id = var.cloudflare_zone_id
    name    = "ssh"
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true 
}

resource "cloudflare_record" "wild" {
    zone_id = var.cloudflare_zone_id
    name    = "*"
    value   = cloudflare_argo_tunnel.all_the_things.cname
    type    = "CNAME"
    proxied = true
}