resource "cloudflare_spectrum_application" "ssh_proxy" {
    zone_id      = var.cloudflare_zone_id
    protocol     = "tcp/22"
    traffic_type = "direct"
    dns {
        type = "CNAME"
        name = "ssh.${var.cloudflare_zone}"
    }

    origin_direct = [
        "tcp://${google_compute_instance.origin.network_interface.0.access_config.0.nat_ip}:22"
    ]
}