resource "random_id" "namespace" {
  prefix      = "ztdesktop-"
  byte_length = 2
}


data "google_compute_image" "os" {
  # Ubuntu 20.04 
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "desktop" {
  name         = random_id.namespace.hex
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["desktop", "ssh"]

  boot_disk {
    initialize_params {
        image = data.google_compute_image.os.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata_startup_script = templatefile(
    "${path.module}/scripts/desktop_script.sh", {
      CRD          = var.chrome_remote_desktop,
      DESKTOP_USER = var.user,
      PIN          = var.pin
    }
  )

  metadata = {
    "cf-terraform" = "zt_desktop"
    "cf-email"     = var.cloudflare_email
  }

  labels = {
    "owner" = split("@", replace(var.cloudflare_email, ".", "_"))[0]
  }
}

output "build_time" {
  description = "Information on build time for this demo."
  value = "Typically it takes ~8 minutes for the script to finish running to create the desktop. Once the desktop reboots you should see it in Chrome Remote Desktop."
}

output "desktop_name" {
  value = random_id.namespace.hex
}

output "post_config" {
  value = "Run 'warp-cli --accept-tos teams-enroll <team name>' on the remote server to enroll WARP in your Account."
}
