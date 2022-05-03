# README

## Summary

This repo is intended to be a demo of an actual deployment of Vault Enterprise into AWS, using the [`vault-ent-starter` Terraform module](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/aws/latest).

The [source code is available on GitHub](https://github.com/hashicorp/terraform-aws-vault-ent-starter) and contains some sample modules that are pre-requisites for running the provider.

## Configuration

This repo copy/pastes the example modules referenced above (under `/modules/`) and provides required variables for them in the main `variables.tf` file.

To supply variables to Terraform, you can use a `terraform.auto.tfvars` file. Please see an example below.

```terraform
vault_version          = "1.9.4"
vault_license_filepath = "/PATH_TO_YOUR_LICENSE_FILE/vault.hclic"
vault_license_name     = "vault.hclic"
resource_name_prefix   = "temp-test"
common_tags = {
  "product" = "vault"
  "owner"   = "YOUR_NAME"
}
azs = [
  "eu-west-1a",
  "eu-west-1b",
  "eu-west-1c"
]
aws_region = "eu-west-1"
```
In the example above, the `vault_license_name` property is the name of the file you want to be created in S3 when the local license file is uploaded. 

`vault_license_filepath` property must be the absolute path to the license file on your local machine. 

Please ensure that the `azs` you want to deploy to are part of the `aws_region` supplied.

You shouldn't commit `terraform.auto.tfvars` to any source code repository!

## Usage

### Prerequisites

* AWS CLI installed
* Terraform installed
* AWS CLI configured (with relevant IAM permissions)
* Terraform configuration modified
* Valid Vault Enterprise license

### Deployment

We now need to create a `VPC` and an `AWS Secrets Manager` __before__ we run the Vault provider.

In the repo, this is a one time action, but is a bit fiddly, and doesn't feel very Terraform'y.

In `main.tf`, you will need to comment out the `module` named `vault-ent-starter`.

```terraform
/*
module "vault-ent-starter" {
  source                 = "hashicorp/vault-ent-starter/aws"
  version                = "0.1.2"
  vault_version          = var.vault_version
  lb_type                = var.lb_type
  vault_license_filepath = var.vault_license_filepath
  vault_license_name     = var.vault_license_name
  resource_name_prefix   = var.resource_name_prefix
  vpc_id                 = module.vpc.vpc_id
  private_subnet_tags    = module.vpc.private_subnet_tags
  lb_certificate_arn     = module.secrets_manager.lb_certificate_arn
  secrets_manager_arn    = module.secrets_manager.secrets_manager_arn
  leader_tls_servername  = module.secrets_manager.leader_tls_servername
}
*/
```

You can now run the standard Terraform commands in your directory:

1. `terraform init`
2. `terraform apply`

Review and accept the plan output in order to apply into AWS. When this is complete you can uncomment `vault-ent-starter` and re-run the Terraform commands above to deploy Vault.

### Initialization

__NOTE:__ These instructions are lifted from the `vault-ent-starter` GitHub repository linked at the top of this README.

We now need to [initialize the Vault cluster](https://www.vaultproject.io/docs/commands/operator/init#operator-init). Log into a node (EC2 instance) via SSH/Session Manager etc. and run the following commands.

```bash
sudo -i
vault operator init
```
You should then see a `Success! Vault is intialized` message along with your `recovery keys` and a `root token`.

Recovery keys should be treated as __secret__ and stored individually.

Export your Vault root token so you can interact with Vault via the CLI.

```bash
export VAULT_TOKEN="<YOUR_VAULT_TOKEN>"
```

You can now unseal Vault using the `vault operator unseal` command and supplying the unseal keys one by one. Once you've unsealed the node the other nodes will automatically be unsealed via the AWS KMS.

## Notes

* Your Vault license file __must__ be stored locally on your filesystem, there currently isn't a way to supply it via `base64` encoded variable etc.

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-aws-vault-ent-starter/blob/main/LICENSE)
for more details.