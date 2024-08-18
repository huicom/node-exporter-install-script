#!/bin/bash

# Function to check if the script is run as root or with sudo
check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
  fi
}

# Function to install Node Exporter
install_node_exporter() {
  echo "Installing Node Exporter..."

  # Download the latest Node Exporter release
  wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
  
  # Extract the Node Exporter tarball
  tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
  
  # Move the Node Exporter binary to /usr/local/bin/
  mv /tmp/node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
  
  # Create a system user for Node Exporter
  useradd -rs /bin/false node_exporter
  
  # Create a systemd service file for Node Exporter
  cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

  # Reload systemd and start Node Exporter service
  systemctl daemon-reload
  systemctl start node_exporter
  systemctl enable node_exporter

  echo "Node Exporter installation completed and service started."
}

# Main script execution
check_root
install_node_exporter
