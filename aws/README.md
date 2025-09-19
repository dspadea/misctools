# AWS Utilities

This directory contains scripts for AWS authentication and ECR login.

## Installation

Copy the scripts in this directory to a location in your `PATH`, such as `/usr/local/bin`:

```bash
chmod +x aws-login.sh ecr-login.sh
cp aws-login.sh /usr/local/bin/
cp ecr-login.sh /usr/local/bin/
```

## Prerequisites

- AWS CLI must be installed
- AWS CLI must be properly configured with credentials

## Usage

Run the scripts directly from your shell:

```bash
aws-login.sh
# or
ecr-login.sh
```

Refer to each script for specific usage details.
