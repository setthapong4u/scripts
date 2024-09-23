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

# Start Kubernetes installation

# Add Kubernetes repository
sudo mkdir -p /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install kubeadm, kubelet, kubectl
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Install necessary utilities (socat for Kubernetes communication)
sudo apt-get install -y socat

# Enable IP forwarding (required for Kubernetes networking)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sysctl -p

# Disable swap
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo swapoff -a

# kubeadm init with containerd and pod network
sudo kubeadm init --pod-network-cidr=10.224.0.0/16 --cri-socket unix:///run/containerd/containerd.sock

# If kubeadm init is successful, continue to set up kubeconfig
if [ $? -eq 0 ]; then
    echo "Kubeadm init completed successfully."

    # Set up kubeconfig for the current user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Calico network plugin for Kubernetes
    kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml

    echo "Kubernetes cluster setup is complete."
else
    echo "Kubeadm init failed. Please check the logs and resolve any issues."
fi
