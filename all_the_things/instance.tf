resource "random_id" "namespace" {
  prefix      = "dlg-"
  byte_length = 2
}

data "google_compute_image" "image" {
  family  = "ubuntu-minimal-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "origin" {
  name         = random_id.namespace.hex
  machine_type = var.machine_type
  zone         = var.zone
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

  provisioner "remote-exec" {
    inline = [
      "sudo apt update", "sudo apt install python3 -y",  "echo Done!"
    ]
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      user = "dlg"
      type = "ssh"
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  -i ${self.network_interface.0.access_config.0.nat_ip}, scripts/main.yml"
  }

  metadata = {
      cf-terraform = "demo_tf_kitchensink"
      cf-email     = var.cloudflare_email
      cf-zone      = var.cloudflare_zone
  } 

  depends_on = [
    local_file.tf_ansible_vars_file
  ]
}