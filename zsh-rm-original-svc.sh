#!/bin/zsh

# Declare an array of services in zsh
services=(
  "build-code-service"
  "health-check-service"
  "internal-proxy-api-service"
  "system-monitor-service"
  "kubernetes-goat-home-service"
  "poor-registry-service"
  "hunger-check-service"
)

# Loop through the services array and delete each service
for svc in $services; do
  echo "Deleting service: $svc"
  kubectl delete svc $svc
  if [ $? -eq 0 ]; then
    echo "Successfully deleted $svc"
  else
    echo "Failed to delete $svc or service not found"
  fi
done

echo "Finish"
