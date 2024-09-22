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

# kubeadm start
sudo kubeadm init --pod-network-cidr=10.224.0.0/16 --cri-socket /run/containerd/containerd.sock

# Set up kubeconfig 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install k8s network
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml
