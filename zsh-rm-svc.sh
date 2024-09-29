#!/bin/zsh

# Checking kubectl setup
kubectl version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "kubectl setup looks good."
else
    echo "Please check kubectl setup."
    exit 1
fi

echo "Removing services created with NodePorts..."

# Declare an associative array with app labels in zsh
typeset -A apps
apps=(
  "build-code" "3000:32030"
  "health-check" "80:32031"
  "internal-proxy" "3000:32032"
  "system-monitor" "8080:32033"
  "kubernetes-goat-home" "80:32034"
  "poor-registry" "5000:32035"
  "hunger-check" "8080:32036"
)

# Loop through the apps and delete the corresponding services
for app in ${(k)apps}; do
  echo "Removing service for app: $app"
  
  if [ "$app" = "hunger-check" ]; then  # Use = instead of ==
    NAMESPACE="big-monolith"
  else
    NAMESPACE="default"
  fi

  # Delete the service for the app
  kubectl delete svc ${app}-service --namespace $NAMESPACE

  if [ $? -eq 0 ]; then
    echo "Successfully removed service for $app"
  else
    echo "Failed to remove service for $app or service not found"
  fi
done

echo "All services have been removed."
