# Azure Vault Deployment

Terraform configuration for deploying a HashiCorp Vault Enterprise cluster on Azure.

This deployment provisions a Vault cluster backed by an Azure Virtual Machine Scale Set (VMSS), with optional Azure Load Balancer and DNS records. Vault bootstrap assets such as the license, TLS certificate, TLS private key, optional CA bundle, and Azure Key Vault auto-unseal key are expected to exist in an Azure Key Vault before deployment.

## What this deployment creates

At a high level, this configuration deploys:

- A resource group, or resources in an existing resource group
- A user-assigned managed identity for Vault
- RBAC and Key Vault access policies required by Vault instances
- A Vault server VMSS
- An optional Azure Load Balancer
- Optional public and/or private DNS records
- Optional Telegraf monitoring setup

## Architecture notes

- Vault runs on a Linux VM Scale Set
- The Vault API is exposed on port `8200`
- Auto-unseal is configured for Azure Key Vault
- Vault instances are spread across Azure availability zones by default
- The VM image is pulled from an Azure Shared Image Gallery image named `hc-base-ubuntu-2404-amd64`
- The `image_factory` provider alias currently points to a fixed subscription in `providers.tf`; update it if your image source differs

## Repository structure

- `main.tf` — root module wiring
- `variables.tf` — root input variables
- `outputs.tf` — root outputs
- `providers.tf` — Terraform and provider configuration
- `terraform.tfvars.example` — example variable values
- `modules/vault/` — implementation of the Azure Vault deployment

## Prerequisites

Before running this deployment, make sure you have:

- Terraform `>= 1.9`
- Azure credentials with permission to create or update:
  - Resource groups
  - Managed identities
  - Role assignments
  - VM Scale Sets
  - Load balancers
  - DNS records
  - Key Vault access policies
- An existing virtual network and subnet(s) for Vault and the load balancer
- An Azure Key Vault containing:
  - Vault license secret
  - Vault TLS certificate secret
  - Vault TLS private key secret
  - Optional CA bundle secret
  - An Azure Key Vault key for auto-unseal
- An SSH public key for VM access
- A DNS zone if you want Terraform to create DNS records

### Prereq Repositories
- TLS Certs: https://github.com/hashicorp-services/terraform-acme-tls-azurerm
  - The outputs from this repository will be the inputs to the Vault Prereqs repo below

- Vault Prereqs: https://github.com/hashicorp-services/terraform-azurerm-prereqs/blob/main/examples/vault-enterprise/README.md
  - The outputs here will be the inputs to the terraform.tfvars of this repository

## Required Azure prerequisites

The example variables assume the following external resources already exist:

1. **Network resources**
   - A virtual network
   - A subnet for Vault instances
   - A subnet for the load balancer when using an internal load balancer

2. **Bootstrap Key Vault**
   - The Key Vault named by `prereqs_keyvault_name`
   - Secrets referenced by:
     - `vault_license_keyvault_secret_id`
     - `vault_tls_cert_keyvault_secret_id`
     - `vault_tls_privkey_keyvault_secret_id`
     - `vault_tls_ca_bundle_keyvault_secret_id` (optional)
   - A key referenced by:
     - `vault_seal_azurekeyvault_unseal_key_name`

3. **Shared image gallery access**
   - Access to the image configured in `modules/vault/compute.tf`
   - If you do not use the default image factory subscription, update the aliased `azurerm.image_factory` provider in `providers.tf`

## Quick start

### 1. Authenticate to Azure

Authenticate with Azure using your preferred workflow, for example:

```bash
az login
az account set --subscription <your-subscription-id>
```

### 2. Create your variable file

Copy the example file and update it for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

At minimum, review and update:
**Most of these will be outputs from the `terraform-azurerm-prereqs` repository**

- `friendly_name_prefix`
- `location`
- `resource_group_name`
- `vault_fqdn`
- `vnet_id`
- `vault_subnet_id`
- `lb_subnet_id`
- `public_dns_zone_name`
- `public_dns_zone_rg`
- `prereqs_keyvault_name`
- `prereqs_keyvault_rg_name`
- `vault_license_keyvault_secret_id`
- `vault_tls_cert_keyvault_secret_id`
- `vault_tls_privkey_keyvault_secret_id`
- `vault_tls_ca_bundle_keyvault_secret_id`
- `vault_seal_azurekeyvault_vault_name`
- `vault_seal_azurekeyvault_unseal_key_name`
- `vm_ssh_public_key`

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the plan

```bash
terraform plan -out=tfplan
```

### 5. Apply the deployment

```bash
terraform apply tfplan
```

## Example configuration

The provided `terraform.tfvars.example` demonstrates a typical deployment with:

- A new resource group
- An external load balancer
- A public DNS record
- Vault Enterprise `1.21.4+ent`
- Telegraf monitoring enabled

## Important inputs

The root module currently passes the following primary inputs into the Vault module.

### Common

- `friendly_name_prefix`
- `location`
- `create_resource_group`
- `resource_group_name`
- `vault_fqdn`
- `vault_version`

### Networking

- `vnet_id`
- `vault_subnet_id`
- `create_lb`
- `lb_subnet_id`
- `lb_is_internal`

### DNS

- `create_vault_public_dns_record`
- `public_dns_zone_name`
- `public_dns_zone_rg`

### Secrets and auto-unseal

- `prereqs_keyvault_rg_name`
- `prereqs_keyvault_name`
- `vault_license_keyvault_secret_id`
- `vault_tls_cert_keyvault_secret_id`
- `vault_tls_privkey_keyvault_secret_id`
- `vault_tls_ca_bundle_keyvault_secret_id`
- `vault_seal_azurekeyvault_vault_name`
- `vault_seal_azurekeyvault_unseal_key_name`

### Compute and monitoring

- `vm_ssh_public_key`
- `enable_telegraf_monitoring`
- `telegraf_config_template`
- `vault_telemetry_config`

## Outputs

After a successful apply, Terraform returns:

- `vault_cli_config` — shell exports for configuring the Vault CLI

You can show the output with:

```bash
terraform output vault_cli_config
```

## Accessing Vault

This deployment builds a CLI configuration snippet that sets:

- `VAULT_ADDR`
- `VAULT_TLS_SERVER_NAME`
- `VAULT_CACERT` when a CA bundle is used

After deployment:

1. Run `terraform output vault_cli_config`
2. Export the environment variables it prints
3. Initialize or log in to Vault as required by your operational workflow

## Monitoring

When `enable_telegraf_monitoring = true`:

- Telegraf installation is added to instance bootstrap
- The Vault managed identity receives the `Monitoring Metrics Publisher` role on the resource group

## Notes and caveats

- `terraform.tfvars` should not be committed with environment-specific secrets
- `.terraform.lock.hcl` should generally be committed to pin provider selections
- The current load balancer rule exposes Vault on port `8200`
- The configuration contains comments about a future `443` frontend rule, but it is not enabled
- Existing tracked state or tfvars files should be removed from Git history or Git index separately if needed

## Destroying the deployment

To tear down the deployed infrastructure:

```bash
terraform destroy
```

Review the destroy plan carefully, especially when using existing shared resources such as DNS zones, virtual networks, or Key Vaults.
