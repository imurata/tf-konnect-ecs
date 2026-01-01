terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    konnect = {
      source = "kong/konnect"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "konnect" {
  personal_access_token = var.konnect_personal_access_token
  server_url            = "https://us.api.konghq.com"
}
