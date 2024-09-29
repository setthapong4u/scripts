#!/bin/bash

# Checking kubectl 
kubectl version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "kubectl setup looks good."
else
    echo "Please check kubectl setup."
    exit
fi

echo "Creating services with NodePorts..."

# Declare an associative array with app labels, target ports, and NodePort values
declare -A apps=(
  ["build-code"]="3000:32030"
  ["health-check"]="80:32031"
  ["internal-proxy"]="3000:32032"
  ["system-monitor"]="8080:32033"
  ["kubernetes-goat-home"]="80:32034"
  ["poor-registry"]="5000:32035"
  ["hunger-check"]="8080:32036"
)

# Loop through the apps and expose each one as a ClusterIP service first, then patch it to use the desired NodePort
for app in "${!apps[@]}"; do
  echo "Exposing app: $app with target port and NodePort: ${apps[$app]}"
  
  # Split the target port and NodePort from the array value
  IFS=":" read -r target_port node_port <<< "${apps[$app]}"

  # Get the pod name for the app
  if [ "$app" == "hunger-check" ]; then
    POD_NAME=$(kubectl get pods --namespace big-monolith -l "app=$app" -o jsonpath="{.items[0].metadata.name}")
    NAMESPACE="big-monolith"
  else
    POD_NAME=$(kubectl get pods --namespace default -l "app=$app" -o jsonpath="{.items[0].metadata.name}")
    NAMESPACE="default"
  fi

  # If pod exists, expose the service
  if [ -n "$POD_NAME" ]; then
    echo "Pod found: $POD_NAME"

    # Expose the pod as a ClusterIP service first
    kubectl expose pod $POD_NAME --namespace $NAMESPACE --name=${app}-service --port=$target_port --target-port=$target_port --type=ClusterIP

    # Now patch the service to use the specific NodePort
    kubectl patch svc ${app}-service --namespace $NAMESPACE -p "{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"port\":$target_port,\"targetPort\":$target_port,\"nodePort\":$node_port}]}}"

    if [ $? -eq 0 ]; then
      echo "Successfully created NodePort service for $app on NodePort $node_port"
    else
      echo "Failed to create NodePort service for $app"
    fi
  else
    echo "No pod found for app: $app. Skipping..."
  fi
done

echo "All NodePort services have been processed."
