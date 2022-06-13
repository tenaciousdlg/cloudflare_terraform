# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "machine_type" {
  description = "GCP VM instance machine type."
  type        = string
}

variable "zone" {
  description = "Zone for GCP instance"
  type        = string
}
# Cloudflare Variables
variable "cloudflare_zone" {
  description = "The Cloudflare Zone to use."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use."
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in."
  type        = string
}

variable "cloudflare_email" {
  description = "The Cloudflare user."
  type        = string
}

variable "cloudflare_token" {
  description = "The Cloudflare user's API token."
  type        = string
}
