#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration Variables (User should modify these) ---
N8N_DOMAIN="n8n.fullztools.es" # Replace with your actual domain or VPS IP
POSTGRES_PASSWORD="09066303384Ug@" # Replace with a strong password
TIMEZONE="Africa/Lagos" # Replace with your desired timezone, e.g., America/New_York

# --- Step 1: Update Your Computer (Server Updates) ---
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# --- Step 2: Install Docker (Our App Container) ---
echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker ${USER}

# --- Step 3: Install Docker Compose ---
echo "Installing Docker Compose..."
sudo apt install docker-compose -y

# --- Step 4: Set Up n8n and PostgreSQL with Docker Compose ---
echo "Setting up n8n and PostgreSQL with Docker Compose..."
mkdir -p ~/n8n_setup
cd ~/n8n_setup

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgresql
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_HOST=${N8N_DOMAIN}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://${N8N_DOMAIN}:5678/
      - GENERIC_TIMEZONE=${TIMEZONE}
      - TZ=${TIMEZONE}
    volumes:
      - ~/.n8n:/home/node/.n8n
    depends_on:
      - postgresql

  postgresql:
    image: postgres:13
    restart: always
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - ~/.n8n_db:/var/lib/postgresql/data
EOF

docker-compose up -d

# --- Step 5: Set Up the Browser Tool (Playwright MCP Server) ---
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Installing Playwright MCP server and browsers..."
sudo npm install -g @modelcontextprotocol/server-playwright
npx playwright install --with-deps

echo "Setting up pm2 for Playwright MCP server..."
sudo npm install -g pm2
pm2 start mcp-server-playwright --name "playwright-mcp"
pm2 save
pm2 startup

echo "
-------------------------------------------------------------------
VPS Setup Complete!

IMPORTANT: You need to log out and log back in to your VPS for Docker group changes to take effect.
After logging back in, you can access n8n at: http://${N8N_DOMAIN}:5678

Remember to configure your PostgreSQL and Playwright MCP credentials in n8n.
-------------------------------------------------------------------
"
