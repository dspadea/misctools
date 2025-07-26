# Misctools

A collection of miscellaneous tools and utilities, organized by topic. These tools are designed to be lightweight, standalone utilities that can generally be added directly to your PATH for convenient command-line access.

Since these are random tools added over time, they may vary in programming language and implementation choices.

**Note**: These tools are often created with significant AI assistance, especially initially, followed by manual fixes and tweaking. They're practical utilities designed to help accomplish specific tasks and work well enough for their intended purposes.

## Structure

Tools are organized into directories by topic:

- **aws/**: AWS-related utilities for authentication and service management
  - `aws-login.sh`: MFA-enabled AWS session token management
  - `ecr-login.sh`: Docker login to AWS ECR repositories

## Installation

### Individual Tools

Most tools are self-contained shell scripts that can be used directly:

```bash
# Make executable and add to PATH
chmod +x aws/aws-login.sh
ln -s $(pwd)/aws/aws-login.sh /usr/local/bin/aws-login

# Or run directly
./aws/aws-login.sh
```

### Bulk Installation

Use the provided justfile to build and install all tools:

```bash
# Install just if you haven't already
# macOS: brew install just
# Ubuntu: sudo apt install just

# Build and install all tools
just install-all
```

## Usage

### AWS Tools

The AWS tools help manage authentication and service access:

```bash
# Authenticate with MFA and create session credentials
./aws/aws-login.sh

# Source the generated session file
source ~/.aws/session.env

# Login to ECR for Docker operations
./aws/ecr-login.sh
```

## Adding New Tools

When adding new tools:

1. Create a topic directory if it doesn't exist
2. Add your script(s) with appropriate permissions (`chmod +x`)
3. Optionally add `build.sh` and `install.sh` scripts for complex tools
4. Update this README with usage examples

## Requirements

- Bash shell
- Topic-specific dependencies (see individual tool documentation)
- For AWS tools: AWS CLI, jq, and configured AWS credentials

## License

See LICENSE file for details.
