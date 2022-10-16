# Cloudflare Terraform WAF Configurations

The following repository is configured into two directories. 
The `account_waf` directory focuses on the new Account level WAF and its configuration. 
The `zone_waf` directory focuses on the new Zone level WAF and its configuration.

```
❯ tree
├── account_waf
│   ├── main.tf
│   ├── rulesets.tf
│   ├── terraform.tfvars
│   └── variables.tf
└── zone_waf
    ├── README.md
    ├── main.tf
    ├── rulesets.tf
    ├── scripts
    │   ├── cf_managed_rules_id.sh
    │   ├── cf_owasp_anomaly_rule.sh
    │   └── cf_owasp_rules_id.sh
    ├── terraform.tfvars
    └── variables.tf
```