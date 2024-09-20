#!/bin/bash

# Install necessary packages
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Create the necessary directory
sudo mkdir -p /etc/apt/keyrings

# Add NodeSource GPG key
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Add NodeSource repository
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Update package list and install Node.js
sudo apt-get update
sudo apt-get install -y nodejs
npm i -g yarn

cd /var/www/pterodactyl # Replace with actual path
yarn
yarn add cross-env

# Install other necessary packages
sudo apt install -y zip unzip git curl wget

# Download the latest release of BlueprintFramework from GitHub
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip

# Move the release to the target directory and unzip it
sudo mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
sudo unzip release.zip

# Configure the Blueprint script
FOLDER="/var/www/pterodactyl"
WEBUSER="www-data"
USERSHELL="/bin/bash"
PERMISSIONS="www-data:www-data"

sudo sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
-e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
-e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" \
$FOLDER/blueprint.sh

# Make the script executable and run it
sudo chmod +x $FOLDER/blueprint.sh
sudo bash $FOLDER/blueprint.sh
