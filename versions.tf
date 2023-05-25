terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.2.0"
}
