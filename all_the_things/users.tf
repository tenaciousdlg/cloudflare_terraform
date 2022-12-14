data "cloudflare_account_roles" "rbac" {
  account_id = var.cloudflare_account_id
}

locals {
  roles_by_name = {
    for role in data.cloudflare_account_roles.rbac.roles :
      role.name => role
  }
}

resource "cloudflare_account_member" "example_user" {
  email_address = "user@example.com"
  account_id = var.cloudflare_account_id
  role_ids = [
    local.roles_by_name["Firewall"].id,
    local.roles_by_name["DNS"].id 
  ]
}

# Documentation at 
# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/account_roles
# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/account_member