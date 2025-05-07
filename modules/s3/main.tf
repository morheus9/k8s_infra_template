# KMS-ключ для шифрования бакета
resource "yandex_kms_symmetric_key" "bucket_key" {
  name         = "bucket-key-${var.bucket_name}"
  description  = "KMS key for bucket encryption"
  folder_id    = var.folder_id
  rotation_period = "8760h" # 1 год
}

# Бакет с шифрованием
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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}