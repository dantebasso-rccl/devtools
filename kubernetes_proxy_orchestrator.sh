#!/bin/bash

## Author: Dante Cesar Basso Filho
## Creation: 21/11/2024
## Version: 0.1

# Clear the screen
clear

# Namespace variable
NAMESPACE="construct"

# Initial local port to start port-forwarding
START_PORT=9090

# List of specific services to port-forward
SERVICES=("alpha-v1" "sir-v1" "capillary-v1" "siebel-v1")

# Current local port to forward to the next service
CURRENT_PORT=$START_PORT

# Array to store the PIDs of the port-forward processes
PIDS=()

# Function to check if the user is authenticated with Kubernetes
check_k8s_auth() {
  # Check if the user can perform any operation, e.g., 'get nodes'
  kubectl auth can-i get nodes > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 0  # User is authenticated and has permissions
  else
    return 1  # User is not authenticated or lacks permissions
  fi
}

# Function to display authentication links
display_authentication_links() {
  echo "You are not authenticated with Kubernetes. Please authenticate first."
  echo "Visit one of the following links to authenticate:"
  echo "TST : https://portal.dkp2.tst.aws-digital.rccl.com/dkp/kommander/dashboard/"
  echo "STG : https://portal.dkp2.tst.aws-digital.rccl.com/dkp/kommander/dashboard/"
  echo "PRD : https://portal.dkp2.tst.aws-digital.rccl.com/dkp/kommander/dashboard/"
  exit 1
}

# Function to display authenticated user's account and environment
display_authenticated_user() {
  # Get the current context and user info
  CONTEXT=$(kubectl config current-context)
  USER=$(kubectl config view --minify -o jsonpath='{.users[0].name}')
  CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
  
  echo "Authenticated to Kubernetes."
  echo "Context: $CONTEXT"
  echo "User: $USER"
  echo "Cluster: $CLUSTER"
  echo "Proceeding with port-forward mapping..."
}

# Check if the user is authenticated
check_k8s_auth

# If authenticated, proceed, else show links to authenticate
echo $? >> /dev/null
if [ $? -eq 0 ]; then
  display_authenticated_user
else
  display_authentication_links
fi

# Trap to handle script termination and cleanup
trap 'echo "Cleaning up port-forward processes..."; kill "${PIDS[@]}"; exit 0' SIGINT SIGTERM

# Loop through the predefined list of services and set up port-forwarding
for SERVICE in "${SERVICES[@]}"; do
  # Get the exposed service port
  SERVICE_PORT=$(kubectl get svc $SERVICE -n $NAMESPACE -o jsonpath='{.spec.ports[0].port}')
  
  echo "Setting up port-forward for $SERVICE on local port $CURRENT_PORT (exposed port $SERVICE_PORT)..."
  
  # Set up port-forwarding in the background and capture the PID
  kubectl port-forward svc/$SERVICE $CURRENT_PORT:$SERVICE_PORT -n $NAMESPACE &
  PIDS+=($!)  # Add the PID to the array
  
  # Increment the local port for the next service
  CURRENT_PORT=$((CURRENT_PORT + 1))
done

echo "Port-forwarding successfully configured for all services!"
wait  # Wait for all background processes to finish
