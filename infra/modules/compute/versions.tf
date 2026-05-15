terraform {
  required_version = ">= 1.5.0"

  required_providers {
    nhncloud = {
      source  = "nhn-cloud/nhncloud"
      version = "= 1.0.8"
    }
  }
}
