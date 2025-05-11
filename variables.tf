variable "service_account_key_file" {
  description = "Yandex Cloud service_account_key_file"
  type        = string
  default     = "/tmp/sa-key.json"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "token" {
  description = "Yandex Cloud OAuth api token"
  type        = string
  default     = "not-used"
}

# k8s
variable "public_access" {
  description = "Public or private Kubernetes cluster"
  type        = bool
  default     = true # <-- Включаем публичный доступ
}

variable "enable_outgoing_traffic" {
  description = "Flag to enable outgoing traffic"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k8s-cluster-test-01"
}

variable "enable_cilium_policy" {
  description = "Flag to enable Cilium policies"
  type        = bool
  default     = true
}

variable "service_ipv4_range" {
  description = "IPv4 range for services"
  type        = string
  default     = "172.20.0.0/16"
}

variable "service_account_name" {
  description = "Name of the cluster's service account"
  type        = string
  default     = "k8s-cluster-test-01-service-account"
}

variable "node_account_name" {
  description = "Name of the cluster's node account"
  type        = string
  default     = "k8s-cluster-test-01-node-account"
}

variable "create_kms" {
  description = "Flag to create a KMS"
  type        = bool
  default     = true
}

variable "node_groups_defaults" {
  description = "Map of common default values for Node groups."
  type        = map(any)
  default = {
    template_name = "{instance_group.id}-{instance.short_id}"
    platform_id   = "standard-v3"
    node_cores    = 4
    node_memory   = 8
    node_gpus     = 0
    core_fraction = 100
    disk_type     = "network-ssd"
    disk_size     = 69
    preemptible   = false
    nat           = false
    ipv4          = true
    ipv6          = false
  }
}
