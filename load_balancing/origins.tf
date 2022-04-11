variable "instances" {
  default = {
      "us" = {
          "zone": "us-west2-b"
      },
      "emea" = {
          "zone": "europe-west1-c"
      },
      "apac" = {
          "zone": "asia-northeast3-a"
      }
  }
}

resource "random_id" "namespace" {
  prefix      = "lbdemo-"
  byte_length = 2
}

data "google_compute_image" "image" {
  # Container Optimized OS 97 LTS
  family  = "cos-97-lts"
  project = "cos-cloud"
}

resource "google_compute_instance" "origins" {
  for_each = var.instances
  name         = "${each.key}-${random_id.namespace.hex}"
  machine_type = var.machine_type
  zone         = each.value.zone
  tags         = ["http-server", "ssh", "https-server"]

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

  metadata_startup_script = <<SCRIPT
    docker run -h ${each.key} -d -p 80:80 tenaciousdlg/html-container
    SCRIPT

  metadata = {
      cf-terraform = "load_balancing"
      cf-email = var.cloudflare_email
      cf-zone = var.cloudflare_zone
  } 

  labels = {
    "owner" = split("@", replace(var.cloudflare_email, ".", "_"))[0]
  }
}