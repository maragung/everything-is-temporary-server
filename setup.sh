#!/bin/bash

SERVICE_NAME="eit-server"
WORK_DIR="$(pwd)"
NODE_VERSION="18"

install_node() {
  if ! command -v node &> /dev/null; then
    echo "[INFO] Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
    sudo apt-get install -y nodejs
  else
    echo "[INFO] Node.js already installed."
  fi
}

install_dependencies() {
  echo "[INFO] Installing npm dependencies..."
  npm install
}

create_service() {
  echo "[INFO] Creating systemd service..."

  sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service" <<EOL
[Unit]
Description=Everything is Temporary WebSocket Server
After=network.target

[Service]
ExecStart=/usr/bin/node $WORK_DIR/server.js
WorkingDirectory=$WORK_DIR
Restart=always
RestartSec=5
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable $SERVICE_NAME
  sudo systemctl restart $SERVICE_NAME
  echo "[SUCCESS] Service created and started."
}

uninstall_service() {
  echo "[INFO] Uninstalling service..."
  sudo systemctl stop $SERVICE_NAME
  sudo systemctl disable $SERVICE_NAME
  sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed
  echo "[SUCCESS] Service uninstalled."
}

start_service() {
  sudo systemctl start $SERVICE_NAME
  echo "[INFO] Service started."
}

stop_service() {
  sudo systemctl stop $SERVICE_NAME
  echo "[INFO] Service stopped."
}

status_service() {
  sudo systemctl status $SERVICE_NAME
}

show_menu() {
  echo "====== Everything is Temporary WebSocket ======"
  echo "1) Install & Setup Service"
  echo "2) Start Service"
  echo "3) Stop Service"
  echo "4) Status Service"
  echo "5) Uninstall Service"
  echo "0) Exit"
  echo "==============================================="
}

while true; do
  show_menu
  read -p "Select an option: " choice
  case $choice in
    1)
      install_node
      install_dependencies
      create_service
      ;;
    2)
      start_service
      ;;
    3)
      stop_service
      ;;
    4)
      status_service
      ;;
    5)
      uninstall_service
      ;;
    0)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
  echo
done
