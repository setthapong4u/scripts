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
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'

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
