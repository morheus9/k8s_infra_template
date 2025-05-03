variable "bucket_name" {
  description = "Имя S3 бакета"
  type        = string
}

variable "bucket_size" {
  description = "Максимальный размер бакета (в байтах)"
  type        = string
  default     = "1073741824" # 1 GB
}

variable "region" {
  description = "Регион Yandex Cloud"
  type        = string
  default     = "ru-central1"
}

variable "folder_id" {
  description = "ID папки в Yandex Cloud"
  type        = string
}
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}
variable "token" {
  description = "Yandex Cloud OAuth api token"
  type        = string
}
