#!/bin/bash

# Update 
sudo apt-get update -y
sudo apt-get upgrade -y

# Install containerd
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Set up K8s repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/keyrings/kubernetes-archive-keyring.gpg >/dev/null
curl -fsSL https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-release-keyring.gpg

# Add the Kubernetes repository to sources.list.d
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-release-keyring.gpg] https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm, kubelet, and kubectl for version 1.30
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# Disable swap (Kubernetes doesn't work with swap enabled)
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo swapoff -a

sudo apt-get install -y socat

# Enable IP forwarding 
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/net.ipv4.ip_forward/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -p

# Initialize K8s Cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket /run/containerd/containerd.sock

# Set up kubeconfig for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml


kubectl taint nodes --all node-role.kubernetes.io/control-plane-


echo "You can enjoy using kubectl with your cluster."
