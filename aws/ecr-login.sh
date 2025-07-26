#!/usr/bin/env bash

set -e


# Use ~/.aws/mfalogin.env if available
MFALOGIN_ENV="$HOME/.aws/mfalogin.env"
if [[ -f "$MFALOGIN_ENV" ]]; then
    echo "[INFO] Loading AWS config from $MFALOGIN_ENV"
    source "$MFALOGIN_ENV"
fi

# List of regions to log in to
ECR_REGIONS=(us-east-1 us-east-2)

# Get AWS Account ID from env or fallback to AWS CLI
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --output text --query Account)}"

for AWS_REGION in "${ECR_REGIONS[@]}"; do
    ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    echo "[INFO] Logging Docker into ECR: $ECR_URL"
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$ECR_URL"
    if [[ $? -eq 0 ]]; then
        echo "[INFO] Docker login to $ECR_URL successful!"
    else
        echo "[ERROR] Docker login to $ECR_URL failed." >&2
        exit 1
    fi
    echo
    # ...next region

done

echo "[INFO] All requested ECR logins complete."
