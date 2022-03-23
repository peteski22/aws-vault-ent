variable "vault_version" {
  type    = string
  default = "1.8.0"
}

variable "lb_type" {
  type    = string
  default = "network"
}

variable "vault_license_filepath" {
  type = string
}

variable "vault_license_name" {
  type = string
}

variable "resource_name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "aws_region" {
  description = "the AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "azs" {
  description = "availability zones to use in AWS region"
  type        = list(string)
  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "peter" {
  type = map(string)
  default = {
    Vault = "deploy"
  }
}