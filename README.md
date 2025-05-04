[![Terraform Deploy](https://github.com/morheus9/k8s_infra_template/actions/workflows/terraform.yml/badge.svg)](https://github.com/morheus9/k8s_infra_template/actions/workflows/terraform.yml)

# Terraform Template for Yandex Cloud Infrastructure

This repository provides a Terraform config for deploying infrastructure for K8s on Yandex Cloud. 
It includes modules for creating and managing various resources, such as:
- Yandex Object Storage (S3)
- Yandex Managed K8S Service for Kubernetes

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [S3 Backend Creation](#s3-backend-creation)
  - [Creation of k8s](#creation-of-k8s)
  - [Deploying Nginx on Kubernetes and Getting the Public IP](#deploying-nginx-on-kubernetes-and-getting-the-public-ip)
- [Variables](#variables)
- [Examples](#examples)
- [Clean Up](#clean-up)
- [Resourses](#resourses)

## Prerequisites

Before you begin, ensure you have the following:

1.  **Yandex Cloud Account:** You'll need an active Yandex Cloud account. If you don't have one, sign up at [Yandex Cloud](https://yandex.cloud/).
2.  **YC CLI:** Install the Yandex Cloud Command Line Interface (YC CLI). Follow the instructions in the [Yandex Cloud documentation](https://yandex.cloud/ru/docs/cli/quickstart).

```bash
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

3.  **Terraform:** Install Terraform.  A common method is using `snap`.

```bash
snap install terraform --classic
```

4.  **Authentication:** Authenticate with Yandex Cloud using the YC CLI.

```bash
yc init
```
    This command will guide you through the process of obtaining an OAuth token and logging in under the required service account.
    
6.  **Terraform Provider Configuration:** Configure Terraform to use the Yandex Cloud provider. Create or edit the `~/.terraformrc` file with the following content:

```bash
cat > ~/.terraformrc <<EOF
  provider_installation {
    network_mirror {
      url = "https://terraform-mirror.yandexcloud.net/"
      include = ["registry.terraform.io/*/*"]
    }
    direct {
      exclude = ["registry.terraform.io/*/*"]
    }
  }
  EOF
```

7.  **Environment Variables:** Export the necessary environment variables for Terraform to access your Yandex Cloud resources.

```bash
export TF_VAR_cloud_id=$(yc config get cloud-id)
export TF_VAR_folder_id=$(yc config get folder-id)
export TF_VAR_token=$(yc iam create-token)
```

## Installation

1.  **Clone the repository:**

```bash
git clone https://github.com/morheus9/terraform_template.git
cd k8s_infra_template
```

## Configuration

Before deploying the infrastructure, you need to configure the variables in the Terraform modules.

## Usage

### S3 Backend Creation

This module creates an S3 bucket in Yandex Object Storage for storing Terraform state or other data.
- **Review Module Variables:**
- **Navigate to the S3 module directory and create backet for backend:**

```bash
cd modules/s3
terraform init
terraform plan -var-file=environments/dev/dev.tfvars
terraform plan -var-file=environments/test/test.tfvars
terraform plan -var-file=environments/prod/prod.tfvars
terraform workspace new dev
terraform workspace new test
terraform workspace new prod
# For dev
terraform workspace select dev
terraform apply -var-file=environments/dev/dev.tfvars -auto-approve
echo AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
echo AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)
# For test
terraform workspace select test
terraform apply -var-file=environments/test/test.tfvars -auto-approve
echo AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
echo AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)
# For prod
terraform workspace select prod
terraform apply -var-file=environments/prod/prod.tfvars -auto-approve
echo AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
echo AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)
```
- **Destroy backend !!!WARNING!!!**
```bash
terraform workspace select dev
terraform destroy -var-file=environments/dev/dev.tfvars
terraform workspace select test
terraform destroy -var-file=environments/test/test.tfvars
terraform workspace select prod
terraform destroy -var-file=environments/prod/prod.tfvars
```
- **Export S3 Credentials:** After the deployment, export the credentials of your service account to allow access to the S3 bucket or add to github.

```bash
export AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)
```

### Creation of k8s

This module deploys a Kubernetes cluster in Yandex Managed Service for Kubernetes.

1.  **Navigate to the root directory and Apply the configuration:**

```bash
cd ../..

terraform workspace new dev
terraform workspace new test
terraform workspace new prod

# Before initializing the backend, you need to add editor rights to the accounts:
sa-terraform-state-backend-dev
sa-terraform-state-backend-test
sa-terraform-state-backend-prod

# dev
terraform workspace select dev
terraform init -backend-config=environments/dev/dev.tfbackend
terraform plan -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/dev/dev.tfvars
# test
terraform workspace select test
terraform init -backend-config=environments/test/test.tfbackend
terraform plan -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/test/test.tfvars
# prod
terraform workspace select prod
terraform init -backend-config=environments/prod/prod.tfbackend
terraform plan -var-file=environments/dev/dev.tfvars
terraform apply -var-file=environments/prod/prod.tfvars
```

2. **Connecting to the Kubernetes Cluster:**

```bash
terraform workspace select dev
eval "$(terraform output -raw internal_cluster_cmd_str)"

terraform workspace select test
eval "$(terraform output -raw internal_cluster_cmd_str)"

terraform workspace select prod
eval "$(terraform output -raw internal_cluster_cmd_str)"
```
This configures `kubectl` to communicate with your Yandex Managed Kubernetes cluster.

### Deploying Nginx on Kubernetes and Getting the Public IP

This example shows how to deploy a simple Nginx web server on the Kubernetes cluster and retrieve the public IP address for accessing it.

1.  **Navigate to the Nginx deployment directory:**

```bash
cd tf/modules/kube
```

2.  **Apply the Nginx deployment:** This command deploys the Nginx deployment, service, and ingress to your Kubernetes cluster.

```bash
kubectl apply -f nginx.yaml
```
    
    This will create:
    *   A `Deployment` named `nginx-deployment` that runs a single replica of Nginx.
    *   A `Service` named `nginx-service` that exposes the Nginx deployment on port 80.
    *   An `Ingress` named `nginx-ingress` that routes external traffic to the `nginx-service`.  The `ingressClassName: "nginx"` specifies that you're using the Nginx ingress controller.

3. **Wait for the Ingress Controller to Assign an IP:** It may take a few minutes for the Yandex Cloud load balancer to provision an external IP address for the Ingress. You can check the status of the Ingress using:

```bash
kubectl get ingress nginx-ingress
```

    Look at the `ADDRESS` column. If it shows `<none>`, the IP is still being provisioned. Keep checking until a public IP address appears.

4.  **Get the external IP address:**  Retrieve the external IP address assigned to the Nginx ingress using `jsonpath`.

```bash
    kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
    
5.  **Access Nginx:** Open your web browser and navigate to the external IP address obtained in the previous step. You should see the default Nginx welcome page. If you don't see the Nginx welcome page, ensure the following:
    * The Ingress has a public IP address assigned.
    * Your Yandex Cloud security groups allow inbound traffic on port 80 (HTTP) and port 443 (HTTPS) to the nodes where Nginx is running. The Terraform Kube module attempts to create these rules, but manual verification may be required if you've customized the security groups.

## Variables

The following environment variables are used by the Terraform modules:

-   `AWS_ACCESS_KEY_ID`:  Access key ID for accessing the S3 bucket.
-   `AWS_SECRET_ACCESS_KEY`: Secret access key for accessing the S3 bucket.
-   `TF_VAR_cloud_id`: Yandex Cloud ID.
-   `TF_VAR_folder_id`: Yandex Folder ID.
-   `TF_VAR_token`: Yandex Cloud OAuth token.

You can also redefine variables using the `-var` flag:

```bash
terraform plan -var="zone=ru-central1-a"
```
Or, use a tfvars file:
```bash
terraform plan -var-file="testing.tfvars"
```
## Examples
K8s Cluster:
```terraform
module "kube" {
  source                  = "./modules/kube"
  node_groups_defaults    = var.node_groups_defaults
  node_groups             = var.node_groups
  enable_outgoing_traffic = var.enable_outgoing_traffic
  cluster_name            = var.cluster_name
  network_id              = module.kube.k8s_network_id
  enable_cilium_policy    = var.enable_cilium_policy
  public_access           = var.public_access
  service_ipv4_range      = var.service_ipv4_range
  service_account_name    = var.service_account_name
  node_account_name       = var.node_account_name
  create_kms              = var.create_kms

  #cluster_version      = "1.28"
  #release_channel      = "REGULAR"
  #folder_id            = "b1g4cr5d305a2bsm2im0"
  #create_kms           = true
  #cluster_ipv4_range   = "172.19.0.0/16"

  master_locations = [
    {
      zone      = var.master_zone
      subnet_id = module.kube.k8s_subnet_ru_central1_a_id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "20:00"
      duration   = "3h"
    }
  ]
}
```
## Clean Up

To destroy the infrastructure created by Terraform, use the following command:

```bash
terraform destroy
```
If you used a tfvars file, specify it during the destroy operation:
```bash
terraform destroy -var-file="testing.tfvars"
```

## Resourses:
- [Setup terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart)
- [Setup terraform backend](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage)
- [Yandex Managed k8s Service for Kubernetes](https://yandex.cloud/ru/docs/managed-kubernetes)
- [K8s from terraform](https://yandex.cloud/ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create)
- [Yandex Object Storage](https://yandex.cloud/ru/docs/storage)
