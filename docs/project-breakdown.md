## 🧩 Project Breakdown

This project is divided into logical phases to provide structure and clarity, ensuring that each part of the homelab redesign is thoughtful, documented, and maintainable. Each phase builds on the previous to support a scalable and automated home infrastructure.

---

### 🔹 Design Phase

The goal of this phase is to understand the current state, define the target architecture, and choose the tools that will support automation and long-term maintainability.

- **Document Existing Network**
  - Map out all current physical and logical connections
  - Identify devices, IP ranges, VLANs, and services
  - Create diagrams (physical, logical, Docker)
  - Audit current firewall rules, DHCP scopes, DNS entries

- **Select Tooling**
  - Decide on infrastructure-as-code tools (e.g., Terraform, Ansible)
  - Choose backup solutions and update mechanisms
  - Select container update tooling (e.g., Watchtower, Renovate)
  - Define CI/CD approach using GitHub Actions
  - Identify monitoring and alerting tools (e.g., Grafana, Uptime Kuma)

- **Define Design Principles**
  - Network segmentation (e.g., IoT, management, services)
  - Security boundaries and least privilege
  - Automation and reproducibility as priorities
  - Documentation-first approach

---

### 🔸 Preparation Phase

This phase focuses on laying the groundwork for a clean and structured environment.

- **Set Up VLANs in the Network**
  - Create VLANs for different device groups (e.g., IoT, Trusted, Guests, Servers)
  - Configure MikroTik router/switch with trunk/access ports
  - Apply basic firewall rules to isolate and control traffic

- **Prepare Raspberry Pi 3**
  - Flash and harden the OS (e.g., Raspberry Pi OS Lite or Ubuntu Server)
  - Assign a static IP and place it in the correct VLAN
  - Install necessary tools (e.g., Docker, SSH, monitoring agent)
  - Set up backups for its configuration and persistent data

- **Create Initial GitHub Repository Structure**
  - Organise directories for Terraform, Ansible, Docker, Diagrams, and Docs
  - Commit baseline network documentation
  - Create `.gitignore`, `README.md`, and project board/issues

- **Bootstrap CI/CD Integration**
  - Configure GitHub Actions with linting, testing, and deployment workflows
  - Set up secrets for accessing devices or APIs securely (e.g., SSH keys, Cloudflare tokens)

---

More detailed implementation and automation (like deploying containers and setting up monitoring) will follow in the **Build Phase** (to be defined), once the foundational design and prep work is complete.
