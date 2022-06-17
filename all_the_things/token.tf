resource "cloudflare_api_token" "logs_account" {
  name = "logs_account"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Access: Audit Logs Read"],
    ]
    resources = {
      "com.cloudflare.api.account.${var.cloudflare_account_id}" = "*"
    }
  }
}

data "cloudflare_api_token_permission_groups" "all" {}

output "dns_read_permission_id" {
  value = data.cloudflare_api_token_permission_groups.all.permissions["DNS Read"] // 82e64a83756745bbbb1c9c2701bf816b
}