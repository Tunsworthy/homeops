# Workflows Documentation

This document lists all GitHub Actions workflows, their purpose, and the relationships between them.

---

## Infrastructure Workflows

### Infrastructure_Dispatcher
**Purpose:** Central workflow for orchestrating infrastructure configuration tasks  
**Scope:** Host  
**Trigger:** Manual (workflow_dispatch)  
**Description:**  
- Allows selection of host (pi3, pi4, etc.) and setup type
- Uses host configuration from `infrastructure/host/hosts-config.yml` to determine runner and environment
- Dispatches to appropriate infrastructure workflow based on selection

**Options:**
- Host network setup
- Docker installation
- Docker network configuration
- Host OS updates
- SSH create-user (creates ansible-admin service account)
- SSH setup-keys (generates SSH keys for cross-Pi access)
- All (runs all configurations except SSH setup)

**Calls:** Network_Setup, Docker_Setup, Docker_Network_Setup, OS_Update, SSH_Setup

---

### SSH_Setup
**Purpose:** Configure cross-Pi SSH administration  
**Scope:** Host  
**Trigger:** Called from Infrastructure_Dispatcher  
**Description:**  
- Creates dedicated `ansible-admin` service account
- Deploys shared SSH key pair from GitHub secrets
- Runs locally on each Pi (localhost execution)
- Enables OS updates to run from one Pi to another
- **No manual key exchange required!**

**Steps:**
- create-user: Creates ansible-admin user with passwordless sudo
- setup-keys: Deploys shared SSH keys from GitHub secrets and configures authorized_keys

**Inputs:**
- host: Target host identifier
- environment: Environment name
- runs_on: Runner to execute on
- step: Which step to execute (create-user or setup-keys)

**Required Secrets:**
- `SSH_ADMIN_PRIVATE_KEY`: Private SSH key for ansible-admin
- `SSH_ADMIN_PUBLIC_KEY`: Public SSH key for ansible-admin
- `SUDO`: Sudo password for runner user

**Playbooks:** 
- `infrastructure/host/ssh/create_admin_user.yml`
- `infrastructure/host/ssh/setup_ssh_keys.yml`

**Called by:** Infrastructure_Dispatcher

**Setup:** Generate keys once using `infrastructure/host/ssh/generate_keys.ps1` (Windows) or `generate_keys.sh` (Linux/Mac), then add to GitHub secrets

---

### OS_Update (Host_Update)
**Purpose:** Update operating system packages on hosts  
**Scope:** Host  
**Trigger:** Called from Infrastructure_Dispatcher  
**Description:**  
- **Cross-Pi Execution:** Runs on the OPPOSITE Pi (pi4 updates pi3, pi3 updates pi4)
- Uses Ansible playbook (`infrastructure/host/os/OS_Updater.yml`) to update OS packages
- Executes as `ansible-admin` user via SSH
- Handles reboot if required (survives via remote SSH connection)
- Captures running Docker containers before update
- Verifies all containers are running after reboot
- Checks for available updates before proceeding

**Inputs:**
- host: Target host identifier (the Pi to be updated)
- environment: Environment name
- runs_on: Runner to execute on (automatically set to opposite host)

**Prerequisites:** SSH setup must be completed (`ansible-admin` user with SSH keys)

**Playbooks:** `infrastructure/host/os/OS_Updater.yml`

**Called by:** Infrastructure_Dispatcher

---

### Network_Setup
**Purpose:** Configure VLANs on the host  
**Scope:** Host  
**Trigger:** Called from Infrastructure_Dispatcher  
**Description:**  
- Configures required VLANs using Netplan
- Uses Jinja2 templates for host-specific VLAN configurations
- Validates VLAN configuration after setup

**Inputs:**
- host: Target host identifier
- environment: Environment name
- runs_on: Runner to execute on

**Playbook:** `infrastructure/host/network/vlan_setup.yml`  
**Called by:** Infrastructure_Dispatcher

---

### Docker_Setup
**Purpose:** Install and configure Docker on hosts  
**Scope:** Host  
**Trigger:** Called from Infrastructure_Dispatcher  
**Description:**  
- Installs Docker using `geerlingguy.docker` Ansible role
- Configures Docker daemon settings
- Sets up Docker user permissions

**Inputs:**
- host: Target host identifier
- environment: Environment name
- runs_on: Runner to execute on

**Playbook:** `infrastructure/host/software/docker-install/docker_setup.yml`  
**Called by:** Infrastructure_Dispatcher

---

### Docker_Network_Setup
**Purpose:** Configure Docker networks on hosts  
**Scope:** Host  
**Trigger:** Called from Infrastructure_Dispatcher  
**Description:**  
- Creates required Docker networks (macvlan, bridge, etc.)
- Configures network settings for container isolation
- Sets up DNS and gateway configurations

**Inputs:**
- host: Target host identifier
- environment: Environment name
- runs_on: Runner to execute on

**Playbook:** `infrastructure/host/software/docker-network/docker_setup_network.yml`  
**Called by:** Infrastructure_Dispatcher

---

## Container Workflows

### Container_Dispatcher
**Purpose:** Orchestrate container deployment pipeline  
**Scope:** Containers  
**Trigger:** 
- Push to `docker/**` paths
- Manual (workflow_dispatch)
- Repository dispatch (API trigger)

**Description:**  
- Detects changed container folders from git push
- Reads container configuration from `docker/<container>/configuration.yml`
- Conditionally executes workflows based on configuration flags:
  - `certificate: true` → Creates Let's Encrypt certificate
  - `dedicated_ip: true` → Allocates IP address
  - `internet_access: true` → Adds IP to Mikrotik NAT allowlist
  - Creates internal DNS A record
  - Deploys container

**Jobs Flow:**
1. `detect-changes` - Identifies which container(s) changed
2. `read-config` - Reads configuration.yml
3. `create-cert` (conditional) - Creates SSL certificate if needed
4. `allocate-ip` (conditional) - Allocates dedicated IP if needed
5. `add-to-nat-allowlist` (conditional) - Adds to Mikrotik firewall if internet access needed
6. `create-internal-a-record` - Creates DNS record
7. `deploy-container` - Deploys the container

**Calls:** CertBot-New-Certs, Container_Allocate-IP, Mikrotik_Add-IP-Allowlist, DNS_Internal_New_A_Recrod, Container_Deployment

---

### Container_Deployment
**Purpose:** Deploy Docker containers using Ansible  
**Scope:** Container  
**Trigger:** Called from Container_Dispatcher  
**Description:**  
- Executes container-specific Ansible playbook (`docker/<container>/container_deploy.yml`)
- Passes allocated IP, FQDN, and other configuration
- Handles container-specific volumes and environment variables

**Inputs:**
- container_name: Name of the container
- environment: Environment name
- allocated_ip: IP address (if dedicated_ip enabled)
- docker_host: Target Docker host
- container_folder: Folder name under docker/
- fqdn: Fully qualified domain name

**Secrets:**
- SUDO: Sudo password for privileged operations
- PFX_PASSWORD: Certificate password (if needed)
- DNS_ADMIN_PASSWORD: DNS admin credentials

**Called by:** Container_Dispatcher

---

### Container_Allocate-IP
**Purpose:** Allocate or reuse IP addresses for containers  
**Scope:** Container  
**Trigger:** Called from Container_Dispatcher (when `dedicated_ip: true`)  
**Description:**  
- Manages CSV-based IPAM at `$HOME/ipam/ipam-{host}.csv`
- Allocates next available IP from subnet (10.2.5.x for pi3, 10.2.6.x for pi4)
- Reuses existing IP if container name already has one
- Returns IP address for use by subsequent workflows

**Inputs:**
- environment: Environment name
- container_name: Container name
- docker_host: Target Docker host

**Outputs:**
- ip_address: Allocated IP address

**Called by:** Container_Dispatcher

---

### Mikrotik_Add-IP-Allowlist
**Purpose:** Add container IP to Mikrotik firewall address list for internet access  
**Scope:** Container  
**Trigger:** Called from Container_Dispatcher (when `internet_access: true`)  
**Description:**  
- Connects to Mikrotik router via RouterOS API (port 8728)
- Adds container IP to "NATAllowed" address list
- Sets container name as comment for identification
- Idempotent (won't duplicate if IP already exists)

**Inputs:**
- environment: Environment name
- container_name: Container name
- allocated_ip: Container IP address
- docker_host: Docker host identifier

**Requirements:**
- Repository Variables: `MIKROTIK_IP`, `MIKROTIK_USER`, `MIKROTIK_PORT`
- Repository Secrets: `MIKROTIK_PASSWORD`
- Python library: `librouteros`
- Ansible collection: `community.routeros`

**Playbook:** `infrastructure/mikrotik/add_to_natallowed.yml`  
**Called by:** Container_Dispatcher

---

### DNS_Internal_New_A_Recrod
**Purpose:** Create internal DNS A records for containers  
**Scope:** Container  
**Trigger:** Called from Container_Dispatcher  
**Description:**  
- Creates A record in Technitium DNS via REST API
- Maps FQDN to allocated IP address
- Updates existing record if already present

**Inputs:**
- environment: Environment name
- allocated_ip: Container IP address
- docker_host: Docker host identifier
- fqdn: Fully qualified domain name

**Secrets:**
- TECHITIUM_DNS_API_KEY: API key for Technitium DNS

**Playbook:** `infrastructure/dns/internal/create_A_record.yml`  
**Called by:** Container_Dispatcher

---

## Certificate Workflows

### CertBot-New-Certs
**Purpose:** Create Let's Encrypt SSL certificates  
**Scope:** Container  
**Trigger:** Called from Container_Dispatcher (when `certificate: true`)  
**Description:**  
- Uses Certbot with DNS-01 challenge via Cloudflare
- Stores certificates in Docker volume `certbot:/etc/letsencrypt/`
- Creates certificate for specified domain

**Inputs:**
- environment: Environment name
- domain_name: Domain name (FQDN from configuration)
- runs_on: Runner/host to execute on

**Secrets:**
- CF_API_TOKEN: Cloudflare API token

**Variables:**
- EMAIL: Email for Let's Encrypt notifications

**Playbook:** `docker/certbot/newcert.yml`  
**Called by:** Container_Dispatcher

---

### CertBot-Update-Certs
**Purpose:** Check and renew expiring Let's Encrypt certificates  
**Scope:** System  
**Trigger:** Manual (workflow_dispatch) or scheduled  
**Description:**  
- Checks all certificates in certbot volume
- Renews certificates expiring within 30 days
- Uses Cloudflare DNS-01 challenge
- Runs on Production self-hosted runner

**Secrets:**
- CF_API_TOKEN: Cloudflare API token

**Variables:**
- EMAIL: Email for Let's Encrypt notifications

---

## Workflow Relationships

```
Infrastructure_Dispatcher (manual)
├── Network_Setup
├── Docker_Setup
├── Docker_Network_Setup
└── OS_Update

Container_Dispatcher (on push to docker/**)
├── read-config (reads configuration.yml)
├── create-cert → CertBot-New-Certs (if certificate: true)
├── allocate-ip → Container_Allocate-IP (if dedicated_ip: true)
├── add-to-nat-allowlist → Mikrotik_Add-IP-Allowlist (if internet_access: true)
├── create-internal-a-record → DNS_Internal_New_A_Recrod
└── deploy-container → Container_Deployment

CertBot-Update-Certs (manual/scheduled)
```

---

## Container Configuration File

Each container has a `configuration.yml` file at `docker/<container>/configuration.yml`:

```yaml
name: container-name
fqdn: service.domain.com
container_host: pi3|pi4
container_environment: network-name

# Orchestration flags
certificate: true|false         # Create Let's Encrypt cert
external_access: true|false     # Expose via Cloudflare Tunnel (pending)
dedicated_ip: true|false        # Allocate static IP
internet_access: true|false     # Add to Mikrotik NATAllowed list
update: true|false              # Auto-update container
```

**Triggers:**
- Push or change to configuration file → Container_Dispatcher workflow
- Container_Dispatcher reads flags and conditionally executes sub-workflows

---

## Folder Structure

```
docker/
  <Container Name>/
    configuration.yml          # GitHub Actions orchestration config
    container_deploy.yml       # Ansible playbook for deployment
    data/                      # Container-specific config files
```
