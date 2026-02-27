#!/bin/bash
# SSH Diagnostics for ansible-admin cross-Pi connectivity

echo "========================================="
echo "SSH Key Diagnostics"
echo "========================================="
echo ""

echo "1. Check if SSH key exists and has correct permissions:"
echo "----"
sudo -u ansible-admin ls -la /home/ansible-admin/.ssh/id_ed25519*
echo ""

echo "2. Check SSH authorized_keys file:"
echo "----"
sudo -u ansible-admin cat /home/ansible-admin/.ssh/authorized_keys
echo ""

echo "3. Check SSH key fingerprint:"
echo "----"
echo "Private key fingerprint:"
sudo -u ansible-admin ssh-keygen -l -f /home/ansible-admin/.ssh/id_ed25519
echo ""
echo "Public key fingerprint:"
sudo -u ansible-admin ssh-keygen -l -f /home/ansible-admin/.ssh/id_ed25519.pub
echo ""

echo "4. Test SSH connection with verbose output:"
echo "----"
sudo -u ansible-admin ssh -v -i /home/ansible-admin/.ssh/id_ed25519 ansible-admin@10.2.4.20 "echo 'SSH test successful'" 2>&1 | grep -E "(key|auth|permission|denied|authenticity)"
echo ""

echo "5. Check SSH config:"
echo "----"
sudo -u ansible-admin cat /home/ansible-admin/.ssh/config
echo ""

echo "========================================="
echo "End Diagnostics"
echo "========================================="
