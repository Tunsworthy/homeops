# SSH Setup for Cross-Pi Administration

## Overview

This setup creates a dedicated `ansible-admin` user on each Pi for cross-Pi SSH administration. This enables OS updates to run from one Pi to another, surviving reboots.

## Architecture

- **Local Execution**: Each runner executes playbooks locally (not via SSH)
- **Dedicated User**: `ansible-admin` service account with passwordless sudo
- **Cross-Pi SSH**: ansible-admin can SSH between Pi3 ↔ Pi4
- **Manual Key Exchange**: Public keys must be manually exchanged after generation

## Setup Process

### Step 1: Create ansible-admin User (on both Pis)

Run via Infrastructure_Dispatcher:
- Host: pi3
- Setup Type: `ssh create-user`

Then repeat for:
- Host: pi4  
- Setup Type: `ssh create-user`

This creates the `ansible-admin` user with:
- Passwordless sudo (`/etc/sudoers.d/ansible-admin`)
- Home directory with `.ssh/` folder
- Member of sudo group

### Step 2: Generate SSH Keys (on both Pis)

Run via Infrastructure_Dispatcher:
- Host: pi3
- Setup Type: `ssh setup-keys`

Then repeat for:
- Host: pi4
- Setup Type: `ssh setup-keys`

This generates:
- ED25519 SSH key pair at `/home/ansible-admin/.ssh/id_ed25519`
- SSH config file with pi3/pi4 host entries
- Displays public key for manual exchange

### Step 3: Exchange Public Keys (Manual)

After both Pis have generated keys:

**Option A: Manual SSH**
1. SSH to pi3: `ssh tom@pi3.tomunsworth.net`
2. Get pi3's public key:
   ```bash
   sudo cat /home/ansible-admin/.ssh/id_ed25519.pub
   ```
3. Copy to pi4's authorized_keys:
   ```bash
   ssh tom@pi4.tomunsworth.net
   sudo -u ansible-admin bash -c "echo 'PASTE_PI3_KEY_HERE' >> /home/ansible-admin/.ssh/authorized_keys"
   ```
4. Repeat in reverse (pi4's key → pi3)

**Option B: Use Helper Playbook**
The `exchange_keys.yml` playbook can help display keys and test connectivity, but still requires manual copy/paste between systems.

### Step 4: Verify SSH Connectivity

Test from pi3:
```bash
sudo -u ansible-admin ssh ansible-admin@10.2.4.10 echo "Success from pi3 to pi4"
```

Test from pi4:
```bash
sudo -u ansible-admin ssh ansible-admin@10.2.4.20 echo "Success from pi4 to pi3"
```

## File Structure

```
infrastructure/host/ssh/
├── create_admin_user.yml    # Creates ansible-admin user locally
├── setup_ssh_keys.yml        # Generates SSH keys locally
└── exchange_keys.yml         # Helper for manual key exchange
```

## Workflows

### SSH_Setup.yml (Reusable Workflow)
- Inputs: host, environment, runs_on, step
- Steps: create-user | setup-keys
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
