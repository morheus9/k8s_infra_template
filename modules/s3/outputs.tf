output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = yandex_storage_bucket.bucket.id
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = yandex_storage_bucket.bucket.bucket
}

output "bucket_url" {
  description = "The URL of the S3 bucket"
  value       = "https://${yandex_storage_bucket.bucket.bucket}.storage.yandexcloud.net/"
}

output "aws_access_key_id" {
  value     = yandex_iam_service_account_static_access_key.s3_keys.access_key
  sensitive = true # Помечаем как чувствительное, чтобы не выводилось в логах
}

output "aws_secret_access_key" {
  value     = yandex_iam_service_account_static_access_key.s3_keys.secret_key
  sensitive = true
}
