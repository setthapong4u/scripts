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

# start k8s

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install kubeadm, kubelet, kubectl
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap 
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo swapoff -a

# kubeadm start
sudo kubeadm init --pod-network-cidr=10.224.0.0/16 --cri-socket /run/containerd/containerd.sock

# Set up kubeconfig 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install k8s network
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml
