resource "cloudflare_worker_script" "cors" {
  name = "cors"
  content = file("workers/cors.js")
}

resource "cloudflare_worker_script" "partyparrot" {
  name = "partyparrot"
  content = file("workers/pparrot.js")
}

resource "cloudflare_worker_route" "cors" {
  zone_id = var.cloudflare_zone_id
  pattern = "*.${var.cloudflare_zone}/*"
  script_name = cloudflare_worker_script.cors.name
}

resource "cloudflare_worker_route" "partyparrot" {
  zone_id = var.cloudflare_zone_id
  pattern = "*party.${var.cloudflare_zone}/*"
  script_name = cloudflare_worker_script.partyparrot.name
}