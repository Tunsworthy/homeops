#!/bin/bash
# Manual SSH Key Setup Fix
# Run this if the automated setup didn't work correctly

SSH_USER="ansible-admin"
SSH_KEY_PATH="/home/$SSH_USER/.ssh/id_ed25519"
AUTHORIZED_KEYS="/home/$SSH_USER/.ssh/authorized_keys"

echo "========================================="
echo "Manual SSH Key Setup Fix"
echo "========================================="
echo ""

# Check if user exists
if ! id "$SSH_USER" &>/dev/null; then
    echo "❌ User $SSH_USER does not exist!"
    exit 1
fi

echo "✅ User $SSH_USER exists"
echo ""

# Check if key files exist
if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "$SSH_KEY_PATH.pub" ]; then
    echo "❌ SSH key files not found at $SSH_KEY_PATH"
    echo ""
    echo "You need to manually copy the SSH key files from GitHub secrets."
    echo ""
    echo "Run these commands as root:"
    echo ""
    echo "cat > $SSH_KEY_PATH <<'EOF'"
    echo "[PASTE PRIVATE KEY HERE - entire block including -----BEGIN and -----END]"
    echo "EOF"
    echo ""
    echo "cat > $SSH_KEY_PATH.pub <<'EOF'"
    echo "[PASTE PUBLIC KEY HERE]"
    echo "EOF"
    echo ""
    exit 1
fi

echo "✅ SSH key files found"
echo ""

# Fix permissions
echo "Fixing SSH key permissions..."
chmod 700 /home/$SSH_USER/.ssh
chmod 600 $SSH_KEY_PATH
chmod 644 $SSH_KEY_PATH.pub

echo "✅ Permissions fixed"
echo ""

# Fix authorized_keys
echo "Ensuring authorized_keys is set up correctly..."
touch $AUTHORIZED_KEYS
chmod 600 $AUTHORIZED_KEYS

# Get public key content
PUBLIC_KEY=$(cat $SSH_KEY_PATH.pub)

# Check if public key is in authorized_keys
if grep -q "$(cat $SSH_KEY_PATH.pub)" $AUTHORIZED_KEYS; then
    echo "✅ Public key already in authorized_keys"
else
    echo "Adding public key to authorized_keys..."
    cat $SSH_KEY_PATH.pub >> $AUTHORIZED_KEYS
    echo "✅ Public key added to authorized_keys"
fi

echo ""
echo "========================================="
echo "SSH Setup Fixed!"
echo "========================================="
echo ""
echo "Test SSH connection:"
echo "sudo -u $SSH_USER ssh -i $SSH_KEY_PATH ansible-admin@10.2.4.20 'echo test'"
echo ""
