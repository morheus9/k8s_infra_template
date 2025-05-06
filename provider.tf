provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = fileexists(var.service_account_key_file) ? var.service_account_key_file : "/tmp/sa-key.json"
  #token     = var.token
}
