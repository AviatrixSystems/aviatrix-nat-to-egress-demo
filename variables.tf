variable "ctrl_username" {}
variable "ctrl_password" {}

locals {
  # Avx or nat
  avx_egress = false
  aws_nat    = true

  # Vpc config
  vpc_cidr = "10.1.0.0/16"
  pod      = "pod150"
  region   = "us-west-2"

  # Aviatrix Egress fqdn rules
  egress_rules = {
    tcp = {
      "aws.amazon.com"      = "443"
      "azure.microsoft.com" = "443"
      "cloud.google.com"    = "443"
      "*.aviatrix.com"      = "443"
      "www.oracle.com"      = "443"
    }
    udp = {
      "dns.google.com" = "53"
    }
  }
}
