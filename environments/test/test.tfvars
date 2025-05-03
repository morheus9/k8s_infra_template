master_zone             = "ru-central1-a"
enable_outgoing_traffic = true
cluster_name            = "k8s-cluster-test-01"
enable_cilium_policy    = true
public_access           = true
service_ipv4_range      = "172.21.0.0/16"
service_account_name    = "k8s-cluster-test-01-service-account"
node_account_name       = "k8s-cluster-test-01-node-account"
create_kms              = true

node_groups_defaults = {
  "test-nodes" = {
    description = "Testing nodes (auto scale)"
    auto_scale = {
      min     = 2
      max     = 4
      initial = 2
    }
    node_cores  = 4
    node_memory = 8
    node_labels = {
      environment = "test"
    }
  }
}
