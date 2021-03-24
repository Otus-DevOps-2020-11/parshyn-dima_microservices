output "external_ip_address_gitlab" {
  value = yandex_compute_instance.gitlab.*.network_interface.0.nat_ip_address
}
output "external_ip_address_runner" {
  value = yandex_compute_instance.runner.*.network_interface.0.nat_ip_address
}
