#!/bin/bash


API_KEY=$(echo ${NEWRELIC_API_KEY})
# Fetch all policies with names containing "Copart" 
policies=$(curl -s -X GET "https://api.newrelic.com/v2/alerts_policies.json" -H "X-Api-Key:$API_KEY")

# Extract policy IDs that have names containing "Copart" 
policy_ids=$(echo "$policies" | jq -r '.policies[] | select(.name | test("Copart")) | .id')

# Check if there are any policies that match the criteria
if [ -z "$policy_ids" ]; then
  echo "No policies found with 'Copart' in their names."
  exit 0
fi

echo "Policies to process:$policy_ids"

# Loop through each policy ID
for POLICY_ID in $policy_ids; do
  
  # Fetch the single condition for the current policy
  condition=$(curl -s -X GET "https://api.newrelic.com/v2/alerts_nrql_conditions.json" -H "X-Api-Key:$API_KEY" -G --data-urlencode "policy_id=$POLICY_ID")

  # Extract the condition ID
  CONDITION_ID=$(echo "$condition" | jq -r '.nrql_conditions[0].id')

  # Define the URL for getting and updating conditions
  URL_2="https://api.newrelic.com/v2/alerts_nrql_conditions/$CONDITION_ID.json"

  # Fetch the current condition JSON
  current_condition=$(curl -s -X GET "https://api.newrelic.com/v2/alerts_nrql_conditions.json" -H "X-Api-Key:$API_KEY" -G --data-urlencode "policy_id=$POLICY_ID")

  # Extract the condition JSON part
  condition_json=$(echo "$current_condition" | jq '.nrql_conditions[0]')

  # Print the extracted JSON
  echo "condition_json:$condition_json"

  # Update the `enabled` value to `false`
  updated_condition=$(echo "$condition_json" | jq '.enabled = false')

  # Ensure the updated condition is valid JSON
  echo "updated_condition:$updated_condition"

  # Manually wrap the updated JSON in the required structure
  updated_json=$(cat <<EOF
{
  "nrql_condition": $updated_condition
}
EOF
  )

  # Print the manually constructed JSON
  echo "updated_json:$updated_json"

  # Send the updated condition back to the API
  response=$(curl -s -X PUT $URL_2 -H "X-Api-Key:$API_KEY" -H "Content-Type: application/json" -d "$updated_json")

  # Print the response from the API
  echo "Update response:$response"
done