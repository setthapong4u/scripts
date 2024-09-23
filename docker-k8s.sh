#!/bin/bash

# Step 1: Update system and install dependencies
echo "Updating system and installing necessary dependencies..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Step 2: Disable Swap (temporary and permanent)
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Step 3: Set up iptables to see bridged traffic
echo "Configuring iptables for bridged traffic..."
sudo modprobe br_netfilter
sudo modprobe overlay

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply the sysctl settings
sudo sysctl --system

# Step 4: Ensure time synchronization (install chrony)
echo "Ensuring time synchronization by installing chrony..."
sudo apt-get install -y chrony
sudo systemctl enable chrony
sudo systemctl start chrony

# Step 5: Install Docker
echo "Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to the Docker group (optional)
sudo usermod -aG docker $USER

# Step 6: Install Kubernetes (Kubeadm, Kubelet, Kubectl) version 1.29
echo "Installing Kubernetes version 1.29..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/keyrings/kubernetes-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet=1.29.0-00 kubeadm=1.29.0-00 kubectl=1.29.0-00

# Prevent automatic updates to Kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start Kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Step 7: Initialize Kubernetes cluster
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version 1.29.0

# Step 8: Configure kubectl for the non-root user
echo "Setting up kubectl for non-root user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 9: Install Calico network
echo "Installing Calico network for pod networking..."
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml

# Step 10: Verify installation
echo "Docker and Kubernetes installation complete."
docker --version
kubelet --version
kubectl version --client

echo "To add worker nodes to this Kubernetes cluster, use the kubeadm join command that was displayed after the kubeadm init step."

# curl -s https://raw.githubusercontent.com/setthapong4u/install-scripts/main/docker-k8s.sh | bash
