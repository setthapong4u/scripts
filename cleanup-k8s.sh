#!/bin/bash

print_header() {
  echo "==========================================="
  echo "$1"
  echo "==========================================="
}

# Reset k8s
print_header "Resetting Kubernetes"
sudo kubeadm reset -f

# Remove k8s
print_header "Removing Kubernetes components (kubeadm, kubelet, kubectl)"
sudo apt-get purge -y kubeadm kubelet kubectl
sudo apt-get autoremove -y

# Stop and disable kubelet
print_header "Stopping and disabling kubelet service"
sudo systemctl stop kubelet
sudo systemctl disable kubelet

# Clean up IP tables
print_header "Cleaning up IP tables"
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Clean up CNI configuration
print_header "Removing CNI configuration"
sudo rm -rf /etc/cni/net.d

# Remove K8s configure files
print_header "Removing Kubernetes configuration files"
sudo rm -rf ~/.kube /etc/kubernetes/ /var/lib/etcd /var/lib/kubelet /var/lib/cni

# Completion message
print_header "Cleanup complete!"
