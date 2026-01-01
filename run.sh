#!/bin/bash

# Load env.sh if it exists
if [ -f "env.sh" ]; then
  source env.sh
fi

# Check if required environment variables are set
if [ -z "$TF_VAR_konnect_personal_access_token" ]; then
  echo "Error: TF_VAR_konnect_personal_access_token is not set."
  echo "Please set it in env.sh or export it in your shell."
  exit 1
fi

COMMAND=$1

if [ "$COMMAND" == "start" ]; then
  # Initialize Terraform
  echo "Initializing Terraform..."
  terraform init

  # Apply Terraform
  echo "Applying Terraform configuration..."
  terraform apply
elif [ "$COMMAND" == "stop" ]; then
  # Destroy Infrastructure
  echo "Destroying infrastructure..."
  terraform destroy
else
  echo "Usage: ./run.sh [start|stop]"
  exit 1
fi
