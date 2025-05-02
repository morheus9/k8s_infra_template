variable "token" {
  description = "Yandex Cloud OAuth api token"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "region" {
  description = "Region for the S3 bucket"
  type        = string
  default     = "ru-central1"
}

# s3

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-s31111"
}
