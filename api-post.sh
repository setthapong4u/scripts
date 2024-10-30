#!/bin/bash

# Function to post a message to the API
post_message() {
    local message=$1
    curl -X POST -H "Content-Type: application/json" --insecure -d "{\"message\": \"$message\"}" "$base_url/hello/post"
}

# Prompt user for the base URL (default port 5000 for HTTP)
read -p "Enter the base URL (e.g., http://api-s.default.svc.cluster.local): " base_url

# Append port 5000 to the base URL if not already specified
if [[ ! "$base_url" =~ ^http://.*:[0-9]+$ ]]; then
    base_url="${base_url}:5000"
fi

# Infinite loop to prompt user for input
while true; do
    read -p "Enter a message to post (or type 'exit' to quit): " user_input

    if [[ "$user_input" == "exit" ]]; then
        break
    fi

    post_message "$user_input"
done
