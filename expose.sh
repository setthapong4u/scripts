#!/bin/bash

prompt_input() {
  read -p "$1: " input
  echo $input
}

deployment_name=$(prompt_input "Enter the deployment name")
service_name=$(prompt_input "Enter the service name")
port=$(prompt_input "Enter the port")
target_port=$(prompt_input "Enter the target port")
namespace=$(prompt_input "Enter the namespace")

kubectl expose deployment $deployment_name --type=NodePort --name=$service_name --port=$port --target-port=$target_port  --namespace=$namespace

echo "Service '$service_name' has been created in namespace '$namespace' to expose deployment '$deployment_name' on port $port (target port $target_port)."

