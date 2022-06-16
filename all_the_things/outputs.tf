output "public_ip" {
  value = google_compute_instance.origin.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  value = random_id.namespace.hex
}

output "tunnel_name" {
  value = random_id.namespace.hex
}