## 🛠️ Ubuntu Updater: Design Principles

The goal is to automate OS updates on Ubuntu hosts using GitHub Actions, while ensuring service availability and system resilience. Below are the initial considerations and guiding principles for the update process.

### 1️⃣ Run from GitHub Actions
- The update workflow should be initiated via a GitHub Action for visibility and consistency.
- Consider whether:
  - Each host should update itself (agent-based/local execution), **or**
  - One host (or GitHub runner) should remotely update the other host.
- Evaluate SSH-based control vs. self-hosted runners for flexibility.

### 2️⃣ Service Failover Strategy
- Explore if a **failover mechanism** is needed:
  - Option A: Proactively migrate core services from Host A to Host B before applying updates.
  - Option B: Simply **verify health of the other host**, and if it fails to recover in time (e.g., 10 minutes), **start core services** on the remaining host. (storage implications of this?)
- Decision should balance complexity with availability requirements.

### 3️⃣ Post-Update Health Check
- After updates and reboot, confirm that the server:
  - Is reachable over SSH
  - Has all critical services running (e.g., Docker containers, NGINX, DNS)
  - Optionally: Report status back to GitHub Action for success/failure tracking
