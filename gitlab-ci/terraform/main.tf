provider "yandex" {
  version                  = "~> 0.47.0"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

locals {
  names = yandex_compute_instance.gitlab[*].name
  ips   = yandex_compute_instance.gitlab[*].network_interface.0.nat_ip_address
  names_runner = yandex_compute_instance.runner[*].name
  ips_runner   = yandex_compute_instance.runner[*].network_interface.0.nat_ip_address
}

resource "local_file" "generate_inventory" {
  content = templatefile("hosts.tpl", {
    names = local.names,
    addrs = local.ips,
    names_runner = local.names_runner,
    addrs_runner = local.ips_runner
  })
  filename = "../ansible/hosts"

  provisioner "local-exec" {
    command = "chmod a-x ../ansible/hosts"
  }

  provisioner "local-exec" {
    when = destroy
    command = "mv ../ansible/hosts ../ansible/hosts.backup"
    on_failure = continue
  }
}

resource "yandex_compute_instance" "gitlab" {
  count = var.instance_size
  name  = "gitlab-${count.index}"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
      size = 30
      type = "network-ssd"
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat = true
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
}

resource "null_resource" "deploy" {
  provisioner "local-exec" {
    command = <<-EOT
      sleep 60 &&
      ansible-playbook ../ansible/provision.yml
    EOT
    working_dir = "../ansible/"
  }

  triggers = {
    addrs = join(",", local.ips),
  }

  depends_on = [local_file.generate_inventory]
}

resource "yandex_compute_instance" "runner" {
  count = var.instance_size
  name  = "runner-${count.index}"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
      size = 30
      type = "network-ssd"
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat = true
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
}

resource "null_resource" "deploy_runner" {
  provisioner "local-exec" {
    command = <<-EOT
      sleep 30 &&
      ansible-playbook ../ansible/provision.yml -e "GITLAB_API_TOKEN= GITLAB_REGISTRATION_TOKEN="
    EOT
    working_dir = "../ansible/"
  }

  triggers = {
    addrs = join(",", local.ips_runner),
  }

  depends_on = [local_file.generate_inventory]
}
