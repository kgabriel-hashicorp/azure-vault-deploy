# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

locals {
  telegraf_config_template  = var.telegraf_config_template != null ? "${path.cwd}/templates/${var.telegraf_config_template}" : "${path.module}/templates/telegraf.conf.tpl"
  telegraf_install_template = var.telegraf_install_template != null ? "${path.cwd}/templates/${var.telegraf_install_template}" : "${path.module}/templates/custom_data_telegraf.sh.tpl"

  telegraf_custom_data_args = var.enable_telegraf_monitoring ? {
    enable_telegraf_monitoring = true
    telegraf_install_function  = templatefile(local.telegraf_install_template, {
      telegraf_version         = var.telegraf_version
      telegraf_config_b64      = base64encode(templatefile(local.telegraf_config_template, {}))
      telegraf_azure_client_id = azurerm_user_assigned_identity.vault.client_id
    })
  } : {
    enable_telegraf_monitoring = false
    telegraf_install_function  = ""
  }
}

resource "azurerm_role_assignment" "resource_group_metrics_publisher" {
  count = var.enable_telegraf_monitoring ? 1 : 0

  scope                = local.resource_group_id
  principal_id         = azurerm_user_assigned_identity.vault.principal_id
  role_definition_name = "Monitoring Metrics Publisher"
}
