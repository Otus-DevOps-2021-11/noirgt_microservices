variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}

variable "region" {
  description = "Region"
  # Значение по умолчанию
  default = "ru-central1"
}

variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  # Описание переменной
  description = "Path to the private key used for provisioners"
}

variable "image_id" {
  description = "Disk image"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "network_id" {
  description = "Network"
}

variable "service_account_key_file" {
  description = "key .json"
}

variable "vm_disk_image" {
  description = "Disk image for reddit vm"
  default     = "reddit-vm-base"
}
