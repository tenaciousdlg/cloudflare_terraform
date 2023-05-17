# OS the server will use
data "google_compute_image" "image" {
  family  = "cos-97-lts"
  project = "cos-cloud"
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
    docker network create demo-net
    docker run -d --name httpbin --net demo-net -p 80:80 kennethreitz/httpbin
    docker run --name tunnel --net demo-net cloudflare/cloudflared:latest tunnel --no-autoupdate run --token ${cloudflare_tunnel.access_tf.tunnel_token}
    SCRIPT
}