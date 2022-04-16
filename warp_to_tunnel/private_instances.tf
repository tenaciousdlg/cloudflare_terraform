resource "random_id" "origin_name" {
  prefix      = "zt-origin-"
  byte_length = 2
}

data "google_compute_image" "image" {
  family  = "ubuntu-minimal-2004-lts"
  project = "ubuntu-os-cloud"
}


data "local_sensitive_file" "cert" {
    filename = pathexpand("~/.cloudflared/cert.pem")
}

resource "google_compute_instance" "origins" {
  for_each = var.instances
  name         = "${each.key}-${random_id.origin_name.hex}"
  machine_type = "f1-micro"
  zone         = each.value.zone
  tags         = []

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }
  
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    preemptible = true
    automatic_restart = false
  }

  metadata_startup_script = templatefile(
    "${path.module}/scripts/private_instances.sh", {
      config_file  = data.local_sensitive_file.cert.content,
      account      = var.cloudflare_account_id,
      tunnel_id    = cloudflare_argo_tunnel.warp_tunnels[each.key].id,
      secret       = random_id.tunnel_secrets[each.key].b64_std
      }
  )

  metadata = {
      cf-terraform = "warp_to_tunnel"
      cf-email = var.cloudflare_email
      cf-zone = var.cloudflare_zone
  } 

  labels = {
    "owner" = split("@", replace(var.cloudflare_email, ".", "_"))[0]
  }
}