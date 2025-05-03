master_zone             = "ru-central1-a"
enable_outgoing_traffic = true
cluster_name            = "k8s-cluster-test-01"
enable_cilium_policy    = true
public_access           = true
service_ipv4_range      = "172.20.0.0/16"
service_account_name    = "k8s-cluster-test-01-service-account"
node_account_name       = "k8s-cluster-test-01-node-account"
create_kms              = true

node_groups = {
  test_default = {
    cores     = 2
    memory    = 4
    disk_size = 50
    count     = 2
  }
}
