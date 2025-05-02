# Terraform Template for Yandex Cloud Infrastructure

This repository provides a Terraform template for deploying infrastructure on Yandex Cloud. It includes modules for creating and managing various resources, such as:
- Yandex Object Storage (S3)
- Yandex Managed Service for Kubernetes (K8S)
- Virtual Machines
- Network Configuration

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [S3 Bucket Creation](#s3-bucket-creation)
  - [Creation of basic infrastructure modules](#creation-of-basic-infrastructure-modules)
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

1.  **Review Module Variables:** Check the variables defined in each module's `variables.tf` file (if exists) and the `README.md` for specifics.  Pay close attention to required variables.

## Usage

### S3 Bucket Creation

This module creates an S3 bucket in Yandex Object Storage for storing Terraform state or other data.

1.  **Navigate to the S3 module directory:**

```bash
cd modules/s3
```

2.  **Initialize Terraform:**

```bash
terraform init
```

3.  **Plan the deployment:**

```bash
terraform plan
```

4.  **Apply the configuration:**

```bash
terraform apply
```

5.  **Export S3 Credentials:** After the deployment, export the credentials of your service account to allow access to the S3 bucket.

```bash
export AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)
```

### Creation of k8s

This module deploys a Kubernetes cluster in Yandex Managed Service for Kubernetes.

1.  **Navigate to the root directory:**

```bash
cd ..
```

2.  **Initialize Terraform with reconfiguration (important after S3 creation):**

```bash
# Для dev
terraform init -backend-config=backend/dev.tfbackend
# Для test
terraform init -backend-config=backend/test.tfbackend
# Для prod
terraform init -backend-config=backend/prod.tfbackend
```

3.  **Apply the configuration:**

```bash
terraform plan
terraform apply
```

5. **Connecting to the Kubernetes Cluster:**

```bash
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
  source     = "./modules/kubernetes"
  network_id = "enpmff6ah2bvi0k10j66"

  master_locations = [
    {
      zone      = "ru-central1-a"
      subnet_id = "e9b3k97pr2nh1i80as04"
    },
    {
      zone      = "ru-central1-b"
      subnet_id = "e2laaglsc7u99ur8c4j1"
    },
    {
      zone      = "ru-central1-c"
      subnet_id = "b0ckjm3olbpmk2t6c28o"
    }
  ]

  node_groups = {
    "yc-k8s-ng-01" = {
      description = "Kubernetes nodes group 01"
      fixed_scale = {
        size = 2
      }
    }
  }
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
- [Yandex Object Storage](https://yandex.cloud/ru/docs/storage)
- [Yandex Managed Service for Kubernetes](https://yandex.cloud/ru/docs/managed-kubernetes)
- [Setup terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart)
- [Setup terraform backend](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage)
- [K8s from terraform](https://yandex.cloud/ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create)