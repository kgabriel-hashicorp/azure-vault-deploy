module "vault-hvd" {
  source = "./modules/vault"

  providers = {
    azurerm               = azurerm
    azurerm.image_factory = azurerm.image_factory
  }

  #------------------------------------------------------------------------------
  # Common
  #------------------------------------------------------------------------------
  friendly_name_prefix  = var.friendly_name_prefix
  location              = var.location
  create_resource_group = var.create_resource_group
  resource_group_name   = var.resource_group_name
  vault_fqdn            = var.vault_fqdn
  vault_version         = var.vault_version

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  vnet_id         = var.vnet_id
  vault_subnet_id = var.vault_subnet_id
  create_lb       = var.create_lb
  lb_subnet_id    = var.lb_subnet_id
  lb_is_internal  = var.lb_is_internal

  #------------------------------------------------------------------------------
  # DNS
  #------------------------------------------------------------------------------
  create_vault_public_dns_record = var.create_vault_public_dns_record
  public_dns_zone_name           = var.public_dns_zone_name
  public_dns_zone_rg             = var.public_dns_zone_rg

  #------------------------------------------------------------------------------
  # Azure Key Vault installation secrets and unseal key
  #------------------------------------------------------------------------------
  prereqs_keyvault_rg_name               = var.prereqs_keyvault_rg_name
  prereqs_keyvault_name                  = var.prereqs_keyvault_name
  vault_license_keyvault_secret_id       = var.vault_license_keyvault_secret_id
  vault_tls_cert_keyvault_secret_id      = var.vault_tls_cert_keyvault_secret_id
  vault_tls_privkey_keyvault_secret_id   = var.vault_tls_privkey_keyvault_secret_id
  vault_tls_ca_bundle_keyvault_secret_id = var.vault_tls_ca_bundle_keyvault_secret_id

  vault_seal_azurekeyvault_vault_name      = var.vault_seal_azurekeyvault_vault_name
  vault_seal_azurekeyvault_unseal_key_name = var.vault_seal_azurekeyvault_unseal_key_name

  #------------------------------------------------------------------------------
  # Compute
  #------------------------------------------------------------------------------
  vm_ssh_public_key = var.vm_ssh_public_key
  vmss_vm_count     = 3
  vm_sku            = "Standard_D2s_v5"
  enable_telegraf_monitoring = var.enable_telegraf_monitoring
  telegraf_config_template = var.telegraf_config_template
  telegraf_azure_auth_mode = var.telegraf_azure_auth_mode
  telegraf_azure_tenant_id = var.telegraf_azure_tenant_id
  telegraf_azure_client_id = var.telegraf_azure_client_id
  telegraf_azure_client_secret = var.telegraf_azure_client_secret
  telegraf_metrics_publisher_principal_id = var.telegraf_metrics_publisher_principal_id

  vault_telemetry_config = var.vault_telemetry_config
}
