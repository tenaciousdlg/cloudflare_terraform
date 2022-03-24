# Cloudflare Terraform Examples
Example Terraform configs of common use cases involving Cloudflare

## Cloudflare Terraform Provider

The documentation for the Cloudflare Terraform Provider can be found [here](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs).

The version of the Cloudflare Provider used for this documentation is `~> 3.0` unless otherwise noted in the `main.tf` file located in the primary example directory (e.g. `./rulesets/main.tf`). 

## Terraform Version

I am using and testing these configurations using Terraform 1.1.7

```bash
❯ terraform --version
Terraform v1.1.7
on darwin_arm64
```

Most configuration should work with versions of Terraform 0.13+ - 1.1.7. If you run into issues please check your version of Terraform first. 

If you see a problem or have a suggestion please feel free to create a [Pull Request](https://opensource.com/article/19/7/create-pull-request-github). 