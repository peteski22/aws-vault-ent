terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

    }
  }
  required_version = ">= 1.1.6"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/aws-vpc"
  resource_name_prefix = var.resource_name_prefix
  aws_region           = var.aws_region
  azs                  = var.azs
  common_tags          = var.common_tags
}

module "secrets_manager" {
  source               = "./modules/aws-secrets-manager-acm"
  aws_region           = var.aws_region
  resource_name_prefix = var.resource_name_prefix
}

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