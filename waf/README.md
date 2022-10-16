# Cloudflare Terraform WAF Configurations

The following repository is configured into two directories. 

The `account_waf` directory focuses on the new Account level WAF and its configuration. 

The `zone_waf` directory focuses on the new Zone level WAF and its configuration.

```
❯ tree
├── account_waf  
│   ├── main.tf  <== contains provider information
│   ├── rulesets.tf  <== main configuration file, rules are created and implemented here
│   ├── terraform.tfvars <== source of input variables for Terraform
│   └── variables.tf  <== variables used in this Terraform config
└── zone_waf
    ├── README.md
    ├── main.tf  <== contains provider information
    ├── rulesets.tf  <== main configuration file, rules are created and implemented here 
    ├── scripts 
    │   ├── cf_managed_rules_id.sh  <== script used to avoid hardcoding ruleset UUID
    │   ├── cf_owasp_anomaly_rule.sh  <== script used to avoid hardcoding rule UUID
    │   └── cf_owasp_rules_id.sh  <== script used to avoid hardcoding ruleset UUID
    ├── terraform.tfvars  <== source of input variables for Terraform
    └── variables.tf  <== variables used in this Terraform config 
```