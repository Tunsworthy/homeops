#!/bin/bash
# Helper script to generate SSH keys for ansible-admin
# Run this once to create the key pair, then add to GitHub secrets

set -e

KEY_NAME="ansible-admin"
KEY_TYPE="ed25519"
KEY_PATH="$HOME/.ssh/${KEY_NAME}"
COMMENT="ansible-admin@homelab"

echo "========================================="
echo "Generating SSH Key Pair for ansible-admin"
echo "========================================="
echo ""

# Check if key already exists
if [ -f "${KEY_PATH}" ]; then
    echo "⚠️  WARNING: Key already exists at ${KEY_PATH}"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    rm "${KEY_PATH}" "${KEY_PATH}.pub"
fi

# Generate the key
echo "Generating ${KEY_TYPE} key pair..."
ssh-keygen -t ${KEY_TYPE} -f "${KEY_PATH}" -N '' -C "${COMMENT}"

echo ""
echo "✅ Key pair generated successfully!"
echo ""
echo "========================================="
echo "GitHub Secret Configuration"
echo "========================================="
echo ""
echo "Add these two secrets to your GitHub repository:"
echo "Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "---"
echo "Secret Name: SSH_ADMIN_PRIVATE_KEY"
echo "---"
echo "Value (copy everything below):"
echo ""
cat "${KEY_PATH}"
echo ""
echo ""
echo "---"
echo "Secret Name: SSH_ADMIN_PUBLIC_KEY"
echo "---"
echo "Value (copy everything below):"
echo ""
cat "${KEY_PATH}.pub"
echo ""
echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo "Private key: ${KEY_PATH}"
echo "Public key: ${KEY_PATH}.pub"
echo ""
echo "⚠️  IMPORTANT: Keep the private key secure!"
echo "   Do NOT commit it to git or share publicly."
echo ""
