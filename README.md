# Blob index and change feed sample

## Getting Started

This sample deploys:

* an Azure Storage Account with blob indexing and change feed enabled
* an Azure Event Hub with capture set up to the storage account
* an Azure Container Instance containing a simulator sending events to the Event Hub

Running the sample causes blobs to be written every few seconds to the storage account.

### Prerequisites

* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
* [Terraform](https://www.terraform.io/downloads.html)

Note: you can also use [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview) to avoid having to install software locally.

### Installation

* `git clone https://github.com/algattik/blob-index.git`

* `cd blob-index`

* Log in with Azure CLI *(in Azure Cloud Shell, skip this step)*:

  ```shell
  az login
  ```

* Run:

  ```shell
  terraform init
  terraform apply
  ```

  When prompted, answer `yes` to deploy the solution.

## Destroying the solution

Run:

```shell
terraform destroy
```
