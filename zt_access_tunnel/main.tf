# This file is sourced from the Example Usage at https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
# Version of Cloudflare provider is declared here along with additional providers needed for our config
# Configure the Cloudflare provider using the required_providers stanza required with Terraform 0.13 and beyond
# You may optionally use version directive to prevent breaking changes occurring unannounced.
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  email      = var.cloudflare_email
  api_key    = var.cloudflare_token
}

provider "google" {
  project    = var.gcp_project_id
}

provider "random" {
}