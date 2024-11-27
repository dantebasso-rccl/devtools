#!/bin/bash

## Author: Dante Cesar Basso Filho
## Creation: 21/11/2024
## Version: 0.3

clear

# Initial local port to start port-forwarding
START_PORT=9090

# List of specific services with namespaces
SERVICES=("construct:alpha-v1" "construct:sir-v1" "construct:capillary-v1" "guest-accounts:accounts-v3")

# Current local port to forward to the next service
CURRENT_PORT=$START_PORT

# Array to store the PIDs of the port-forward processes
PIDS=()

check_k8s_auth() {
  kubectl cluster-info > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

display_authentication_links() {
  echo "You are not authenticated with Kubernetes. Please authenticate first."
  echo "Visit one of the following links to authenticate:"
  echo "TST : https://portal.dkp2.tst.aws-digital.rccl.com/dkp/kommander/dashboard/"
  echo "STG : https://portal.dkp2.stg.aws-digital.rccl.com/dkp/kommander/dashboard/"
  echo "PRD : https://portal.dkp2.prd.aws-digital.rccl.com/dkp/kommander/dashboard/"
  echo ""
  echo "After login, go to the right top, where is your name and then click on 'Generate Token'. Follow the steps and try again."
  exit 1
}

display_authenticated_user() {
  CONTEXT=$(kubectl config current-context)
  USER=$(kubectl config view --minify -o jsonpath='{.users[0].name}')
  CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
  
  echo "Authenticated to Kubernetes."
  echo "Context: $CONTEXT"
  echo "User: $USER"
  echo "Cluster: $CLUSTER"
  echo "Proceeding with port-forward mapping..."
  echo ""
}

check_k8s_auth

if [ $? -eq 0 ]; then
  display_authenticated_user
else
  display_authentication_links
fi

trap 'echo "Cleaning up port-forward processes..."; kill "${PIDS[@]}"; exit 0' SIGINT SIGTERM

for SERVICE_ENTRY in "${SERVICES[@]}"; do
  # Split namespace and service name

  IFS="::" read -r NAMESPACE SERVICE <<< "$SERVICE_ENTRY"

  # Get the exposed service port
  #SERVICE_PORT=$(kubectl get svc "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].port}')
  SERVICE_PORT=80
  
  if [ -z "$SERVICE_PORT" ]; then
    echo "Error: Unable to fetch port for $SERVICE in namespace $NAMESPACE."
    continue
  fi
  
  #echo "Setting up port-forward for $SERVICE on local port $CURRENT_PORT (exposed port $SERVICE_PORT, namespace $NAMESPACE)..."
  echo "DEBUG  port-forward svc/"$SERVICE" "$CURRENT_PORT":"$SERVICE_PORT" -n "$NAMESPACE""

  printf "  %-20s -> localhost:%d\n" "$SERVICE" "$CURRENT_PORT"

  
  # Set up port-forwarding in the background and capture the PID
  kubectl port-forward svc/"$SERVICE" "$CURRENT_PORT":"$SERVICE_PORT" -n "$NAMESPACE" &
  PIDS+=($!)
  
  # Increment the local port for the next service
  CURRENT_PORT=$((CURRENT_PORT + 1))
done

echo ""
echo "Port-forwarding successfully configured for all services!"
echo ""
wait
