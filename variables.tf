variable "ctrl_username" {
  description = "Aviatrix controller user name"
}

variable "ctrl_password" {
  description = "Aviatrix controller password"
}

variable "ctrl_ip" {
  description = "Aviatrix controller ip or domain name"
}

variable "aws_account" {
  description = "Name of the AWS cloud account onboarded to Aviatrix"
  default     = "aws-account"
}

locals {
  # Avx or nat
  avx_egress = false
  aws_nat    = true

  # Avx Secure Egress
  avx_security_enforce = false

  # Vpc config
  vpc_cidr = "10.1.0.0/16"
  region   = "us-east-1"
}
