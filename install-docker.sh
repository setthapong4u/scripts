#!/bin/bash

# this script for ubuntu 20.04 - 24.04
set -ex

echo "Updating package list..."
sudo apt-get update

echo "Installing dependencies..."
sudo apt-get install -y ca-certificates curl

echo "Creating directory for Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

echo "Setting permissions for Docker GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo "Adding Docker repository to Apt sources..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


echo "Updating package include Docker packages..."
sudo apt-get update

echo "install docker"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "add current user to docker group"
sudo usermod -aG docker $USER

echo "All steps completed successfully!"

#END of script
