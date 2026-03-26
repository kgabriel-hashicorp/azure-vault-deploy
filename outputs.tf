####Certs####

# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

output "vault_cli_config" {
  value = <<-EOF
    Set the following environment variables to configure the Vault CLI:

    ${module.vault-hvd.vault_cli_config}
  EOF
}
