provider "aviatrix" {
  username                = var.ctrl_username
  password                = var.ctrl_password
  controller_ip           = var.ctrl_ip
  skip_version_validation = false
}

provider "aws" {
  region = local.region
}
