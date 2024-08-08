#!/bin/bash

read -p "Enter the pod name: " POD_NAME

if [ -z "$POD_NAME" ]; then
  echo "Error: Pod name cannot be empty"
  exit 1
fi

NODE_NAME=$(kubectl get pod $POD_NAME -o jsonpath='{.spec.nodeName}')

if [ -z "$NODE_NAME" ]; then
  echo "Error: Could not retrieve node name for pod $POD_NAME"
  exit 1
fi

NODE_IP=$(kubectl get node $NODE_NAME -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

if [ -z "$NODE_IP" ]; then
  echo "Error: Could not retrieve IP address for node $NODE_NAME"
  exit 1
fi

echo "The IP address of the node ($NODE_NAME) hosting pod $POD_NAME is: $NODE_IP"

