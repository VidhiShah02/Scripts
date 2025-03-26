#!/bin/bash

# Fetch all application names in the peddle-dev namespace
applications=$(kubectl get applications -n argocd -o jsonpath='{.items[*].metadata.name}')

# Loop through each application and disable sync
for app in $applications; do
  echo "Disabling sync for application: $app"
  kubectl patch application $app --type='merge' -p '{"spec": {"syncPolicy": null}}' -n argocd
done