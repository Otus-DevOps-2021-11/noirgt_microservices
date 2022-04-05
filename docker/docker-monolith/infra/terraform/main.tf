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
  count                    = var.subnet_id == false ? 1 : 0

  source                   = "./modules/vpc"
  network_name             = "reddit-app-network"
  subnet_name              = "${var.subnet_name}"
  v4_cidr_blocks           = ["${var.subnet_cidr}"]
}

locals {
  vms                      = {
    "kubemaster"      : {"cpu": 2, "memory": 2},
    "1-kubeworker"    : {"cpu": 2, "memory": 2},
    "2-kubeworker"    : {"cpu": 2, "memory": 2},
  }
}

module "vm" {
  for_each                 = var.vm_name == false ? local.vms : {
    "${var.vm_name}": {"cpu": "${var.vm_cpu}", "memory": "${var.vm_memory}"}
  }

  source                   = "./modules/vm"
  vm_name                  = "vm-${each.key}"
  public_key_path          = var.public_key_path
  vm_disk_image            = var.vm_disk_image
  subnet_id                = var.subnet_id == false ? module.vpc[0].vm-subnet.id : var.subnet_id
  private_key_path         = var.private_key_path

  cpu                      = each.value["cpu"]
  memory                   = each.value["memory"]
}

module "ansiblecall" {
  for_each                 = toset(["kube-dependencies.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.vpc,
    module.vm
  ]
}

module "ansiblecall-wireguard" {
  for_each                 = toset(["wireguard.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.ansiblecall
  ]
}

module "ansiblecall-kubemaster" {
  for_each                 = toset(["kubernetes/master.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.ansiblecall-wireguard
  ]
}

module "ansiblecall-kubeworkers" {
  for_each                 = toset(["kubernetes/workers.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.ansiblecall-kubemaster
  ]
}
