terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.69.0"
    }
  }
  backend "s3" {
    key    = "terraform-states/ya-vm-docker.tfstate"
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "vpc" {
  source                   = "./modules/vpc"
  network_name             = "reddit-app-network"
  subnet_name              = "reddit-docker-subnet"
  v4_cidr_blocks           = ["192.168.8.0/24"]
}

module "vm" {
  count                    = 2
  source                   = "./modules/vm"
  vm_name                  = "reddit-vm-${count.index}-docker"
  public_key_path          = var.public_key_path
  vm_disk_image            = var.vm_disk_image
  subnet_id                = module.vpc.vm-subnet.id
  private_key_path         = var.private_key_path

  cpu                      = 2
  memory                   = 2
}

module "ansiblecall" {
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  depends_on               = [
    module.vpc,
    module.vm
  ]
}
