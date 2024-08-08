#!/bin/bash

YAML_FILE=".boxwithsvc.yml"

if [ -f "$YAML_FILE" ]; then
  kubectl delete -f "$YAML_FILE"
else
  echo "Error: $YAML_FILE not found."
  exit 1
fi

