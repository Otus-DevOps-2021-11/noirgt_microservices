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
  for_each                 = {
    "gitlab-ci"    : {"cpu": 2, "memory": 6},
    "gitlab-runner": {"cpu": 2, "memory": 4},
    "app-docker"   : {"cpu": 2, "memory": 2},
    "registry-hub" : {"cpu": 2, "memory": 2}
  }

  source                   = "./modules/vm"
  vm_name                  = "vm-${each.key}"
  public_key_path          = var.public_key_path
  vm_disk_image            = var.vm_disk_image
  subnet_id                = module.vpc.vm-subnet.id
  private_key_path         = var.private_key_path

  cpu                      = each.value["cpu"]
  memory                   = each.value["memory"]
}

module "ansiblecall" {
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = "gitlab-ci.yml"
  depends_on               = [
    module.vpc,
    module.vm
  ]
}
