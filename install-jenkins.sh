#!/bin/bash

echo "Updating system packages..."
sudo apt update -y

echo "Installing Java..."
sudo apt install openjdk-11-jdk -y

echo "Adding Jenkins repository key..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null


echo "Adding Jenkins repository to the system..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null


echo "Updating package lists after adding Jenkins repository..."
sudo apt update -y


echo "Installing Jenkins..."
sudo apt install jenkins -y


echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins


echo "Jenkins installation complete. Your Jenkins initial admin password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "You can access Jenkins at: http://your-server-ip:8080"
