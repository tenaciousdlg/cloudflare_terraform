# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

# Cloudflare Variables
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
  description = "Please type 6 digits to use as a login pin with Chrome Remote Desktop.\ne.g. 123456"
  type = string
}

variable "user" {
  description = "Your GCP user. Typically the same as your workstation user.\nIf you're not sure run 'env | grep '^USER' and use that value."
  type = string
}

variable "chrome_remote_desktop" {
  description = "The variable starts with DISPLAY from Chrome Remote Desktop. Please paste it here."
  type = string
}

variable "instances" {
  default = {
      "emea" = {
          "zone": "europe-west1-c"
      },
      "apac" = {
          "zone": "asia-northeast3-a"
      }
  }
}
