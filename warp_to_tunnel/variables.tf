# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "machine_type" {
  description = "GCP VM instance machine type."
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

variable "zone" {
  description = "GCP zone name."
  type        = string
}
# Chrome Remote Desktop Variables
variable "pin" {
  description = "String of digits used to login to the Chrome Remote Desktop. Must be 6 digits; e.g. 123456"
  type = string
}

variable "user" {
  description = "Your GCP user. Typically the same as your workstation user. If you're not sure run 'env | grep '^USER' and use that value."
  type = string
}

variable "chrome_remote_desktop" {
  description = "The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here."
  type = string
}