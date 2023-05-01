# AWS VPC Definition
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nat-vpc"
  cidr = local.vpc_cidr

  azs             = ["${local.region}a"]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 4, 0)]
  private_subnets = [cidrsubnet(local.vpc_cidr, 4, 1)]

  enable_nat_gateway = local.aws_nat
  enable_vpn_gateway = false
}

# Test instance in private subnet
module "instance" {
  source     = "../infra-avx-labs/_modules/mc-instance"
  name       = "aws-egress-instance"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.private_subnets[0]
  cloud      = "aws"
  public_key = file("~/.ssh/id_rsa.pub")
  password   = var.ctrl_password
  user_data_templatefile = templatefile("${path.module}/egress.tpl",
    {
      name     = "aws-egress-instance"
      password = var.ctrl_password
  })
}

# Aviatrix Secure Egress FQDN Gateway
resource "aviatrix_gateway" "egress" {
  cloud_type     = 1
  account_name   = "aws-account"
  gw_name        = "avx-egress"
  vpc_reg        = local.region
  gw_size        = "t3.micro"
  vpc_id         = module.vpc.vpc_id
  subnet         = module.vpc.public_subnets_cidr_blocks[0]
  single_ip_snat = local.avx_egress ? true : false
}
