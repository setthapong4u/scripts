#!/bin/bash

# Function to install Docker
install_docker() {
  echo "Please exit and start again with containerd. Kubernetes officially deprecated Docker as a CRI starting from version 1.20"
 
}

# Function to install containerd
install_containerd() {
  echo "Installing containerd..."
  sudo apt-get install -y containerd
  sudo mkdir -p /etc/containerd
  containerd config default | sudo tee /etc/containerd/config.toml
  sudo systemctl restart containerd

  echo "Containerd installation complete."
}

# Function to prompt for user input
prompt_user_choice() {
  while true; do
    echo "Choose container runtime:"
    echo "1) Docker"
    echo "2) Containerd"
    read -r -p "Enter choice [1-2]: " choice

    if [[ "$choice" == "1" ]]; then
      install_docker
      break
    elif [[ "$choice" == "2" ]]; then
      install_containerd
      break
    else
      echo "Invalid choice. Please enter 2."
    fi
  done
}

# Call the function to prompt the user
prompt_user_choice

# Load necessary kernel modules for containers and Kubernetes networking
echo "Loading kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

# Add Kubernetes repository
echo "Creating keyrings directory for Kubernetes..."
sudo mkdir -p /etc/apt/keyrings

echo "Adding Kubernetes repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing Kubernetes GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Updating package list..."
sudo apt-get update

echo "Installing Kubernetes components (kubeadm, kubelet, kubectl)..."
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Setup networking requirements
echo "Configuring network settings for Kubernetes..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'

# Apply sysctl changes
sudo sysctl --system
sudo apt-get install -y socat

# Disable swap as required by Kubernetes
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Instructions to proceed with kubeadm init (for master node) or kubeadm join (for worker nodes)
echo -e "\nInstallation complete. You can now initialize the master node with the following command:"
echo "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo "Or join a worker node using the kubeadm join command provided by the master node after initialization."
