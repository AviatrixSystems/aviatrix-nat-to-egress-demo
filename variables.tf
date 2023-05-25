variable "ctrl_username" {}
variable "ctrl_password" {}
variable "ctrl_ip" {}

locals {
  # Avx or nat
  avx_egress = false
  aws_nat    = true

  # Avx dfw
  avx_dfw_enforce = false
  # Vpc config
  vpc_cidr = "10.1.0.0/16"
  region   = "us-east-1"
}
