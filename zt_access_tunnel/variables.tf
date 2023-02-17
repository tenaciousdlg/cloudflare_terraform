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
  description = "GCP zone name."
  type        = string
}
# Cloudflare Variables
variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use."
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

variable "zt_org" {
  description = "Name of Cloudflare Zero Trust organization. Found in ZT dash under Settings > Account"
  type        = string
}

# Identity provider variables
variable "idp_id" {
  description = "ID of Identity Provider (idp) application; often called client id"
  type        = string
}

variable "idp_secret" {
  description = "Key affiliated with idp application; often called client secret"
  type        = string
}

# Demo variables 
variable "application_dns" {
  description = "primary hostname of demo application"
  type        = string
}