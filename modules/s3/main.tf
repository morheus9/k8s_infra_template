# Создаем бакет
resource "yandex_storage_bucket" "bucket" {
  bucket    = var.bucket_name
  max_size  = var.bucket_size
  folder_id = var.folder_id
  acl       = "private"

  versioning {
    enabled = true
  }

  #lifecycle {
  #  prevent_destroy = true # защита от удаления
  #}
}

# Сервисный аккаунт для доступа к бакету
resource "yandex_iam_service_account" "s3_user" {
  name        = "sa-${var.bucket_name}"
  folder_id   = var.folder_id
  description = "Service account for S3 access to ${var.bucket_name}"
}

# Назначаем права на бакет
resource "yandex_iam_service_account_iam_binding" "bucket_access" {
  service_account_id = yandex_iam_service_account.s3_user.id
  role               = "storage.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.s3_user.id}"
  ]
}

# Генерируем статические ключи
resource "yandex_iam_service_account_static_access_key" "s3_keys" {
  service_account_id = yandex_iam_service_account.s3_user.id
  description        = "Static key for ${var.bucket_name}"
}
