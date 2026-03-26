function install_telegraf {
  TELEGRAF_VERSION="${telegraf_version}"

  # Download Telegraf
  cd /tmp
  wget -q https://dl.influxdata.com/telegraf/releases/telegraf-$${TELEGRAF_VERSION}_linux_amd64.tar.gz

  # Extract
  tar xf telegraf-$${TELEGRAF_VERSION}_linux_amd64.tar.gz

  # Install directories
  sudo mkdir -p /usr/local/bin
  sudo mkdir -p /etc/telegraf

  # Install binary
  sudo cp telegraf-$${TELEGRAF_VERSION}/usr/bin/telegraf /usr/local/bin/

  # Install rendered config
  echo "${telegraf_config_b64}" | base64 -d | sudo tee /etc/telegraf/telegraf.conf >/dev/null
  sudo chmod 0644 /etc/telegraf/telegraf.conf

  # Create telegraf user
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin telegraf || true

  # Create systemd service
  sudo tee /etc/systemd/system/telegraf.service >/dev/null <<EOF
  [Unit]
  Description=Telegraf
  After=network.target

  [Service]
  Type=simple
  User=telegraf
  Environment=AZURE_CLIENT_ID=${telegraf_azure_client_id}
  ExecStart=/usr/local/bin/telegraf --config /etc/telegraf/telegraf.conf
  Restart=always
  RestartSec=5

  [Install]
  WantedBy=multi-user.target
EOF

  # Reload systemd
  sudo systemctl daemon-reload

  # Enable and start
  sudo systemctl enable telegraf
  sudo systemctl start telegraf

  # Show status
  sudo systemctl status telegraf --no-pager
}
