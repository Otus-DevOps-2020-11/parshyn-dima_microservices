provider "yandex" {
  version                  = "~> 0.35.0"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

locals {
  names = yandex_compute_instance.docker[*].name
  ips   = yandex_compute_instance.docker[*].network_interface.0.nat_ip_address
}

resource "local_file" "generate_inventory" {
  content = templatefile("hosts.tpl", {
    names = local.names,
    addrs = local.ips
  })
  filename = "../hosts"

  provisioner "local-exec" {
    command = "chmod a-x ../hosts"
  }

  provisioner "local-exec" {
    when = destroy
    command = "mv ../hosts ../hosts.backup"
    on_failure = continue
  }
}

resource "yandex_compute_instance" "docker" {
  count = var.instance_size
  name  = "docker-${count.index}"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
      size = 5
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
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
      sleep 30 &&
      ansible-playbook playbooks/install_docker.yml && ansible-playbook playbooks/run_container.yml
    EOT
    working_dir = "../."
  }

  triggers = {
    addrs = join(",", local.ips),
  }

  depends_on = [local_file.generate_inventory]
}
