# SSH Setup for Cross-Pi Administration

## Overview

This setup creates a dedicated `ansible-admin` user on each Pi for cross-Pi SSH administration. This enables OS updates to run from one Pi to another, surviving reboots.

**Key Feature:** Uses a **shared SSH key pair** stored in GitHub secrets - **no manual key exchange required!**

## Architecture

- **Local Execution**: Each runner executes playbooks locally (not via SSH)
- **Dedicated User**: `ansible-admin` service account with passwordless sudo
- **Shared SSH Keys**: Single key pair stored in GitHub secrets, deployed to both Pis
- **Cross-Pi SSH**: ansible-admin can SSH between Pi3 ↔ Pi4 using the shared key
- **Zero Manual Steps**: Fully automated setup

## Prerequisites

### Create SSH Key Pair (One-Time Setup)

On your local machine or any system with SSH:

```bash
# Generate ED25519 key pair (recommended for security and performance)
ssh-keygen -t ed25519 -f ~/.ssh/ansible-admin -N '' -C 'ansible-admin@homelab'

# View private key (you'll paste this into GitHub)
cat ~/.ssh/ansible-admin

# View public key (you'll paste this into GitHub)
cat ~/.ssh/ansible-admin.pub
```

### Add to GitHub Secrets

In your GitHub repository:

1. Go to: **Settings** → **Secrets and variables** → **Actions**
2. Add two new **Repository secrets**:

   - **Name:** `SSH_ADMIN_PRIVATE_KEY`  
     **Value:** Paste the entire contents of the **private key** including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`

   - **Name:** `SSH_ADMIN_PUBLIC_KEY`  
     **Value:** Paste the entire contents of the **public key** (single line starting with `ssh-ed25519 ...`)

## Setup Process

### Step 1: Create ansible-admin User (on both Pis)

Run via Infrastructure_Dispatcher:
- Host: **pi3**
- Setup Type: **ssh create-user**

Then repeat for:
- Host: **pi4**  
- Setup Type: **ssh create-user**

This creates the `ansible-admin` user with:
- Passwordless sudo (`/etc/sudoers.d/ansible-admin`)
- Home directory with `.ssh/` folder
- Member of sudo group

### Step 2: Deploy SSH Keys (on both Pis)

Run via Infrastructure_Dispatcher:
- Host: **pi3**
- Setup Type: **ssh setup-keys**

Then repeat for:
- Host: **pi4**
- Setup Type: **ssh setup-keys**

This automatically:
- ✅ Deploys private key from GitHub secret to `/home/ansible-admin/.ssh/id_ed25519`
- ✅ Deploys public key from GitHub secret to `/home/ansible-admin/.ssh/id_ed25519.pub`
- ✅ Adds public key to `/home/ansible-admin/.ssh/authorized_keys`
- ✅ Creates SSH config with pi3/pi4 host entries
- ✅ Tests SSH connectivity to the other Pi
- ✅ **No manual steps required!**

### Step 3: Verify (Optional)

SSH to either Pi and test:

```bash
# On pi3, test connection to pi4
sudo -u ansible-admin ssh ansible-admin@10.2.4.10 echo "Success from pi3 to pi4"

# On pi4, test connection to pi3
sudo -u ansible-admin ssh ansible-admin@10.2.4.20 echo "Success from pi4 to pi3"
```

## File Structure

```
infrastructure/host/ssh/
├── create_admin_user.yml    # Creates ansible-admin user locally
├── setup_ssh_keys.yml        # Deploys SSH keys from GitHub secrets
└── exchange_keys.yml         # (Deprecated - not needed with shared keys)
```

## Required GitHub Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SSH_ADMIN_PRIVATE_KEY` | Private SSH key for ansible-admin | `-----BEGIN OPENSSH PRIVATE KEY-----\n...` |
| `SSH_ADMIN_PUBLIC_KEY` | Public SSH key for ansible-admin | `ssh-ed25519 AAAA... ansible-admin@homelab` |
| `SUDO` | Sudo password for runner user | `your_sudo_password` |
- **Automatically deploys SSH keys from GitHub secrets**

### Infrastructure_Dispatcher.yml
- New options:
  - `ssh create-user` - Creates ansible-admin user
  - `ssh setup-keys` - Deploys shared SSH keys from GitHub secrets
- Calls SSH_Setup.yml with appropriate parameters

## Why Shared Keys?

**Benefits:**
- ✅ **Zero manual steps** - fully automated
- ✅ **One-time setup** - generate key once, use everywhere
- ✅ **Consistent keys** - same key on all hosts
- ✅ **Easy rotation** - update GitHub secret, re-run workflow
- ✅ **Secure storage** - keys stored in GitHub encrypted secrets

**Security Note:**
The shared key is only used for cross-Pi administration within your internal network (10.2.4.x). It's not exposed externally.
- Runs locally on specified runner
- Called by Infrastructure_Dispatcher

### Infrastructure_Dispatcher.yml
- New options:
  - `ssh create-user` - Creates ansible-admin user
  - `ssh setup-keys` - Generates SSH keys
- Calls SSH_Setup.yml with appropriate parameters

## Why Localhost Execution?

The GitHub Actions `runner` account:
- ❌ Cannot SSH (permission denied)
- ❌ Cannot authenticate to remote hosts
- ✅ CAN run local playbooks with sudo

Solution:
- Run playbooks locally on each Pi
- Use `hosts: localhost` and `connection: local`
- Each runner configures its own system
- Manual step exchanges keys between systems

## OS Update Flow (After SSH Setup)

1. User triggers: Infrastructure_Dispatcher → Host: pi3 → Setup Type: host OS Update
2. OS_Update workflow runs on **pi4** runner (opposite host)
3. Creates inventory with pi3 as target (10.2.4.20)
4. Runs as `sudo -u ansible-admin` to execute playbook
5. OS_Updater.yml connects via SSH to pi3 using ansible-admin's keys
6. Updates install, system reboots
7. Ansible reconnects automatically after reboot
8. Verifies Docker containers are running

Pi3 and Pi4 update each other - both systems stay online during the process.
