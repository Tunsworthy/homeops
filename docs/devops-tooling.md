## Tooling

### 🛠️ Terraform *(Infrastructure as Code – Planned)*

- **Purpose:** Declaratively manage network devices (e.g. MikroTik routers), virtual machines (Ubuntu servers), and potentially cloud resources in the future.
- **DevOps Role:** Source-controlled infrastructure definitions ensure consistent deployments and easy rollback of changes.
- **Use Cases:**
  - Define VLANs and firewall rules on MikroTik
  - Provision virtual machines and network settings
  - Manage DNS records or public IP endpoints via APIs

---

### 🤖 Ansible *(Configuration Management – Planned)*

- **Purpose:** Automate system configuration, package installation, service management, and OS patching.
- **DevOps Role:** Idempotent and versioned provisioning for base OS configuration and application layer setup.
- **Use Cases:**
  - Install and configure software on Raspberry Pi
  - Enforce system hardening policies
  - Manage Docker host environments and file permissions
  - Schedule regular OS and security patching

---

### 📁 GitHub *(Source Control & Collaboration)*

- **Purpose:** Host the entire configuration, code, documentation, and diagrams in one central, version-controlled repository.
- **DevOps Role:** Acts as the **single source of truth** for all infrastructure and automation code. Enables change tracking, issue management, and team collaboration.
- **Use Cases:**
  - Store Terraform and Ansible playbooks
  - Maintain configuration files (e.g., NGINX, Docker Compose, firewall rules)
  - Track project tasks and issues
  - Store diagrams and architecture docs

---

### 🚀 GitHub Actions *(CI/CD & Automation)*

- **Purpose:** Automate testing, validation, and deployment tasks when code is pushed to GitHub.
- **DevOps Role:** Provides Continuous Integration and Continuous Deployment pipelines, enabling automated updates to staging/production environments.
- **Use Cases:**
  - Validate Terraform plans before deployment
  - Lint and syntax-check Ansible playbooks
  - Automatically trigger deployments to test environments
  - Schedule nightly backups or container updates
  - Push changes to Cloudflare or remote devices using secure SSH workflows

---

### 🐳 Docker *(Application Containerization)*

- **Purpose:** Run all services in isolated, reproducible containers to simplify deployment and improve portability.
- **DevOps Role:** Containers ensure services are immutable and consistent across environments.
- **Use Cases:**
  - Deploy services such as DNS, NGINX, monitoring tools (e.g., Grafana/Prometheus), and home automation platforms (e.g., Home Assistant)
  - Automate builds and updates using CI pipelines

---

### 📦 Watchtower / Renovate *(Container Updates – Future)*

- **Purpose:** Monitor and automatically update Docker containers when new versions are released (with testing/staging).
- **DevOps Role:** Automates part of the Continuous Delivery cycle with guardrails in place.
- **Use Cases:**
  - Auto-update non-critical containers in staging
  - Manual promotion to production after validation

---

### 🔐 Cloudflare *(Reverse Proxy & Access Control)*

- **Purpose:** Securely expose selected services to the internet via a managed reverse proxy and WAF.
- **DevOps Role:** Acts as a secure edge with features like caching, SSL termination, rate limiting, and DDoS protection.
- **Use Cases:**
  - Public access to NGINX reverse proxy
  - Domain management and DNS automation (via Terraform)
  - Zero Trust access policies

---

### 📉 Monitoring & Logging *(Optional – Future)*

- **Prometheus + Grafana** for metrics
- **Loki** or **ELK Stack** for centralized logging
- **Uptime Kuma** or **Healthchecks.io** for external service monitoring

These tools will provide observability into system health, uptime, and performance, allowing for proactive management and alerting.
