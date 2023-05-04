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
resource "tls_private_key" "ec2_instance" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_instance" {
  key_name   = "aws-egress-instance"
  public_key = tls_private_key.ec2_instance.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "ec2_instance" {
  name        = "aws-egress-instance-sg"
  description = "Instance security group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "aws-egress-instance-sg"
  }
}

resource "aws_security_group_rule" "ec2_instance" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_instance.id
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "aws-egress-instance"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ec2_instance.key_name
  vpc_security_group_ids = [aws_security_group.ec2_instance.id]
  subnet_id              = module.vpc.private_subnets[0]
  user_data = templatefile("${path.module}/egress.tpl",
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
