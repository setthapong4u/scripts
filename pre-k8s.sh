#!/bin/bash

# Function to install Docker
install_docker() {
  echo "Installing Docker..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  # Enable Docker services
  sudo systemctl enable docker
  sudo systemctl start docker
  echo "Docker installation complete."
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

# Ask user to choose Docker or containerd
while true; do
  echo "Choose container runtime:"
  echo "1) Docker"
  echo "2) Containerd"
  read -p "Enter choice [1-2]: " choice

  # Validate user input and break if valid
  if [[ "$choice" == "1" ]]; then
    install_docker
    break
  elif [[ "$choice" == "2" ]]; then
    install_containerd
    break
  else
    echo "Invalid choice. Please enter 1 or 2."
  fi
done

# Add Kubernetes repo and install kubeadm, kubelet, kubectl
echo "Installing Kubernetes components (kubeadm, kubelet, kubectl)..."
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/kubernetes-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Setup networking requirements
echo "Configuring network settings for Kubernetes..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply sysctl changes
sudo sysctl --system

# Disable swap as required by Kubernetes
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Instructions to proceed with kubeadm init (for master node) or kubeadm join (for worker nodes)
echo -e "\nInstallation complete. You can now initialize the master node with the following command:"
echo "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo "Or join a worker node using the kubeadm join command provided by the master node after initialization."
