enable_outgoing_traffic = true
cluster_name            = "k8s-cluster-prod-01"
enable_cilium_policy    = true
public_access           = true
service_ipv4_range      = "172.22.0.0/16"
service_account_name    = "k8s-cluster-prod-01-service-account"
node_account_name       = "k8s-cluster-prod-01-node-account"
create_kms              = true
