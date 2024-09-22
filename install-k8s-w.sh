#!/bin/bash

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install containerd
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd 
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install Kubernetes tools

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install kubeadm, kubelet, kubectl
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap 
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo swapoff -a

# Prompt user for control plane IP and token
read -p "Enter the control plane IP address (e.g., 192.168.0.1): " CONTROL_PLANE_IP
read -p "Enter the token you got from the master node: " TOKEN
read -p "Enter the discovery-token-ca-cert-hash (sha256:<hash>): " CA_CERT_HASH

# kubeadm join (use the control plane token and IP provided by the user)
sudo kubeadm join ${CONTROL_PLANE_IP}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash ${CA_CERT_HASH} --cri-socket /run/containerd/containerd.sock

echo "Worker node has successfully joined the Kubernetes cluster"
#kubectl label node k-w node-role.kubernetes.io/worker=
