master_zone             = "ru-central1-a"
enable_outgoing_traffic = true
cluster_name            = "k8s-cluster-test-01"
enable_cilium_policy    = true
public_access           = true
service_ipv4_range      = "172.21.0.0/16"
service_account_name    = "k8s-cluster-test-01-service-account"
node_account_name       = "k8s-cluster-test-01-node-account"
create_kms              = true


node_groups = {
  "k8s-node-group-test-01" = {
    description = "Kubernetes node group with auto scaling"
    auto_scale = {
      min     = 2
      max     = 4
      initial = 2
    }
    instance_template = {
      platform_id = "standard-v2"
      resources = {
        memory = 4 # GB
        cores  = 2 # vCPU
      }
      boot_disk = {
        type = "network-hdd"
        size = 50 # GB
      }
    }
  }
}
