// Control the IdP
resource "cloudflare_access_identity_provider" "google_workspace" {
  account_id = var.cloudflare_account_id
  name       = "Google Workspace"
  type       = "google-apps"
  config {
    apps_domain   = "chrisdlg.com"
    client_id     = var.idp_id
    client_secret = var.idp_secret
    redirect_url  = "https://${var.zt_org}.cloudflareaccess.com/cdn-cgi/access/callback"
  }
}

// Create the Access application
resource "cloudflare_access_application" "tunnel_app" {
  account_id                = var.cloudflare_account_id
  name                      = "example terraform application"
  domain                    = cloudflare_record.access.hostname
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}
// Create the policy for the Access application
resource "cloudflare_access_policy" "tunnel_app" {
  application_id = cloudflare_access_application.tunnel_app.id
  account_id     = var.cloudflare_account_id
  name           = "example terraform app policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email = ["${var.cloudflare_email}"]
    // DEBUG: Possibly https://github.com/cloudflare/terraform-provider-cloudflare/issues/1752
    //gsuite {
    //  identity_provider_id = cloudflare_access_identity_provider.google_workspace.id
    //}
  }
}