resource "yandex_compute_instance" "vm1" {
  name        = "prometheus"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.test1.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta-data.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }

  connection {
    type = "ssh"
    user = "kim"
    host = self.network_interface[0].nat_ip_address
  }

  provisioner "file" {
    source      = "./prometheus.service/prometheus.service.txt"
    destination = "/home/kim/prometheus.service.txt"
  }

  provisioner "file" {
    source      = "./prometheus.service/prometheus-2.53.0-rc.0.linux-amd64.tar.gz"
    destination = "/home/kim/prometheus-2.53.0-rc.0.linux-amd64.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo groupadd --system prometheus",
      "sudo useradd -s /sbin/nologin --system -g prometheus prometheus",
      "sudo mkdir /etc/prometheus",
      "sudo mkdir /var/lib/prometheus",
      "sudo apt update",
      "tar vxf prometheus*.tar.gz",
      "cd prometheus*/",
      "sudo mv prometheus /usr/local/bin",
      "sudo mv promtool /usr/local/bin",
      "sudo chown prometheus:prometheus /usr/local/bin/prometheus",
      "sudo chown prometheus:prometheus /usr/local/bin/promtool",
      "sudo mv consoles /etc/prometheus",
      "sudo mv console_libraries /etc/prometheus",
      "sudo mv prometheus.yml /etc/prometheus",
      "sudo chown prometheus:prometheus /etc/prometheus",
      "sudo chown -R prometheus:prometheus /etc/prometheus/consoles",
      "sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries",
      "sudo chown -R prometheus:prometheus /var/lib/prometheus",
      "sudo mv /home/kim/prometheus.service.txt /etc/systemd/system/prometheus.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable prometheus",
      "sudo systemctl start prometheus",
    ]
  }

}

resource "yandex_compute_disk" "test1" {
  name     = "test1"
  type     = "network-hdd"
  size     = 10
  image_id = "fd82eqhia940tgpmnlj4"

  labels = {
    environment = "test1"
  }
}

resource "yandex_vpc_network" "network-1" {}

resource "yandex_vpc_subnet" "subnet-1" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.0.0/24"]
}
