#!/bin/bash

# Load necessary kernel modules
echo "Loading necessary kernel modules for containerd and Kubernetes..."
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Apply sysctl parameters required by Kubernetes
echo "Setting sysctl parameters for Kubernetes..."
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Install containerd
echo "Installing containerd..."
sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd
echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart and verify containerd status
echo "Restarting containerd and verifying status..."
sudo systemctl restart containerd
sudo systemctl status containerd --no-pager

# Disable swap (required by Kubernetes)
echo "Disabling swap..."
sudo swapoff -a

# Install apt-transport-https and curl
echo "Installing apt-transport-https and curl..."
sudo apt-get update
sudo apt-get install -y apt-transport-https curl

# Add Kubernetes GPG key for version 1.29
echo "Adding Kubernetes GPG key for version 1.29..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository for version 1.29
echo "Adding Kubernetes repository for version 1.29..."
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
EOF

# Update package lists and install Kubernetes components (version 1.29)
echo "Installing Kubernetes components (kubelet, kubeadm, kubectl) version 1.29..."
sudo apt-get update
sudo apt-get install -y kubelet=1.29.0-00 kubeadm=1.29.0-00 kubectl=1.29.0-00

# Hold Kubernetes packages to prevent automatic upgrades
echo "Holding Kubernetes packages..."
sudo apt-mark hold kubelet kubeadm kubectl

# Script completed
echo "Setup complete. System is ready for Kubernetes 1.29 initialization."
# curl -s https://raw.githubusercontent.com/setthapong4u/install-scripts/main/k8s-129.sh | bash
