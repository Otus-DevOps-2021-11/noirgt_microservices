terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.69.0"
    }
  }
}

resource "yandex_compute_instance" "vm" {
  name = var.vm_name

  labels = {
    tags = var.vm_name
  }
  resources {
    cores  = var.cpu
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
     ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

