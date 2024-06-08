terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.token
  folder_id = "aaaaaaaaaaaaaaa"
  cloud_id  = "bbbbbbbbbbbbbbb"
  zone      = "ru-central1-b"
}
