#!/bin/bash

# List of services (Modify as needed or pass as arguments)
SERVICES=("comm-daemon"  "comm-proxy-service"  "uni-net-base-image-demo-client"  "uni-analytics-alert-processing-service"  "ped-net-base-image"  "uni-parameter-store-service"  "api-service-net-image"  "test-automation-service"  "fin-frost-daemon"  "pub-external-offer-service"  "test-universal-service"  "cha-external-offer-service")

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

