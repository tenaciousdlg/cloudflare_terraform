# OS the server will use
data "google_compute_image" "image" {
  family  = "ubuntu-minimal-2004-lts"
  project = "ubuntu-os-cloud"
}

# GCP Instance resource 
resource "google_compute_instance" "origin" {
  name         = "dlg-tforigin"
  machine_type = var.machine_type
  zone         = var.zone
  // Your tags may differ. This one instructs the networking to not allow access to port 22
  //tags         = ["no-ssh"]

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
  // Optional config to make instance ephemeral 
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
  // This is where we configure the server (aka instance)
  metadata_startup_script = <<SCRIPT
    # Add cloudflare gpg key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    # Add this repo to your apt repositories
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
    # install cloudflared
    sudo apt-get update && sudo apt-get install cloudflared
    sudo sudo cloudflared service install ${cloudflare_tunnel.access_tf.tunnel_token}
    sudo apt install -y nginx
    SCRIPT
}