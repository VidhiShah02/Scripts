#!/bin/bash

# List of services (Modify as needed or pass as arguments)
SERVICES=("app1" "app2" ...)

# Use arguments if provided, otherwise use default list
if [ "$#" -gt 0 ]; then
    SERVICES=("$@")
fi

# Namespace (change if required)
NAMESPACE="peddle-prod"

# Loop through each service in the list
for SERVICE in "${SERVICES[@]}"; do
    echo "Rolling out restart for $SERVICE in namespace $NAMESPACE..."
    kubectl rollout restart deployment "$SERVICE" -n "$NAMESPACE"
    if [ $? -eq 0 ]; then
        echo "Successfully restarted $SERVICE"
    else
        echo "Failed to restart $SERVICE"
    fi
done

echo "All services processed."

