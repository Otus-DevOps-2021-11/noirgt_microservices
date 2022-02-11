terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.69.0"
    }
  }
}

resource "null_resource" "check_ssh_availability" {
    connection {
    type        = "ssh"
    host        = var.external_ip_address_vm
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
    }
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install python"
    ]
  }
}

resource "null_resource" "ansible_deploy" {
  provisioner "local-exec" {
      command = "cd $ansible_path && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i $invetory $playbook"
      environment = {
          ansible_path   = "../ansible"
          invetory       = "inventory.py"
          playbook       = "playbooks/site.yml"
      }
    }
    depends_on = [
      null_resource.check_ssh_availability
    ]
}
