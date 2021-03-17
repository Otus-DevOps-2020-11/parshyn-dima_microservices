terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    yandex = {
      source = "terraform-providers/yandex"
    }
  }
  required_version = ">= 0.13"
}
