provider "aviatrix" {
  username                = var.ctrl_username
  password                = var.ctrl_password
  controller_ip           = "ctrl.${local.pod}.aviatrixlab.com"
  skip_version_validation = false
}

provider "aws" {
  profile = local.pod
  region  = local.region
}
