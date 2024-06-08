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
  folder_id = "b1g5n8seedm7iub1qbob"
  cloud_id  = "aje789a9p2bcauis64hl"
  zone      = "ru-central1-b"
}