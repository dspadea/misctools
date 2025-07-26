#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="$HOME/.aws/mfalogin.env"
SESSION_FILE="$HOME/.aws/session.env"
SESSION_DURATION=3600

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_error()  { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

print_warning "If AWS tools are running slowly, try disabling IPv6 on your system."
echo

# Load or create config
if [[ -f "$CONFIG_FILE" ]]; then
    print_status "Loading config from $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    print_status "No config found, auto-detecting..."
    AWS_REGION=$(aws configure get region 2>/dev/null || echo "")
    [[ -z "$AWS_REGION" ]] && AWS_REGION="us-east-1"
    IDENTITY=$(aws sts get-caller-identity --output json)
    AWS_ACCOUNT_ID=$(echo "$IDENTITY" | jq -r .Account)
    ARN=$(echo "$IDENTITY" | jq -r .Arn)
    
    # Extract username from ARN (handles both user and role formats)
    AWS_USERNAME=$(echo "$ARN" | sed -n 's|.*/user/\([^/]*\)$|\1|p')
    [[ -z "$AWS_USERNAME" ]] && AWS_USERNAME=$(echo "$ARN" | sed -n 's|.*/\([^/]*\)$|\1|p')
    
    MFA_DEVICE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${AWS_USERNAME}"
    cat > "$CONFIG_FILE" <<EOF
AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
AWS_REGION="$AWS_REGION"
AWS_USERNAME="$AWS_USERNAME"
MFA_DEVICE_ARN="$MFA_DEVICE_ARN"
SESSION_DURATION="$SESSION_DURATION"
EOF
    print_status "Config saved to $CONFIG_FILE"
fi

# Validate config
for var in AWS_ACCOUNT_ID AWS_REGION AWS_USERNAME MFA_DEVICE_ARN; do
    if [[ -z "${!var}" ]]; then
        print_error "Missing $var in config. Edit $CONFIG_FILE and try again."
        exit 1
    fi
done

echo
read -p "Enter your MFA token: " MFA_TOKEN
if [[ ! "$MFA_TOKEN" =~ ^[0-9]{6}$ ]]; then
    print_error "Invalid MFA token format. Please enter a 6-digit code."
    exit 1
fi


print_status "Requesting session token from AWS..."
CREDS=$(aws sts get-session-token \
    --duration-seconds "$SESSION_DURATION" \
    --serial-number "$MFA_DEVICE_ARN" \
    --token-code "$MFA_TOKEN" \
    --output json 2>&1) || { print_error "Failed to get session token:"; echo "$CREDS" | head -10; exit 1; }

ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')
EXPIRATION=$(echo "$CREDS" | jq -r '.Credentials.Expiration')

if [[ "$ACCESS_KEY_ID" == "null" || -z "$ACCESS_KEY_ID" ]]; then
    print_error "Failed to extract credentials from AWS response."
    exit 1
fi

cat > "$SESSION_FILE" <<EOF
# AWS Session Environment Variables
# Generated: $(date)
# Expires: $EXPIRATION
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$SESSION_TOKEN"
export AWS_DEFAULT_REGION="$AWS_REGION"
# Account: $AWS_ACCOUNT_ID
# Username: $AWS_USERNAME
# MFA Device: $MFA_DEVICE_ARN
EOF

print_status "✅ Session file created at: ${YELLOW}$SESSION_FILE${NC}"
echo -e "${GREEN}To use these credentials, run:${NC} source ~/.aws/session.env"