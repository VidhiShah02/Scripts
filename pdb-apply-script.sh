#!/bin/bash

# Fetch all application names in the peddle-dev namespace
applications=$(kubectl get deployment -n peddle-dev -o jsonpath='{.items[*].metadata.name}')

# Loop through each application and disable sync
for app in $applications; do
  echo "Disabling PDB for application: $app"
  kubectl patch pdb $app --type='merge' -p '{"spec":{"maxUnavailable": null, "minAvailable": 0}}' -n peddle-dev
done
