## 📝 Project Brief

Over time, my homelab has grown organically as I’ve experimented with different tools, services, and ideas. Eventually, I reached a point where things became messy—manual deployments, inconsistent configurations across projects, and little to no backup of critical settings. I’ve been living dangerously, relying on a fragile setup with no easy path to recovery if something breaks.

Recently, while working more with Home Assistant, it became clear that I need a dedicated test environment to avoid breaking my live setup. That was the tipping point. I decided it was time to step back and properly redesign my homelab.

Given that I spend my professional life designing and documenting enterprise environments, I’ve decided to take the same structured approach at home—treating this as an opportunity to apply architectural thinking, automation, and best practices. This project is both a rebuild and a showcase: a well-documented, secure, and resilient environment that reflects how I approach systems design in the real world.

---

## Current Issues

- Containers are outdated; upgrading across many versions is difficult.
- No automation for the deployment of infrastructure services—keeping things up to date is inefficient.
- No backup of configurations, creating high risk during changes (e.g., OS updates are avoided due to fear of failure).
- Undocumented and "complex" network.
- Devices in the IoT VLAN have internet access, which was never intended but evolved over time.
- Containers currently reside in the IoT VLAN; these should be separated out.
- No 'DR' if my primary devices goes down my home is offline

---

## Design Principles

- Only devices/services that require internet access should have it.
- Only containers that require their own IP address should receive one (e.g., DNS, NTP, NGINX).
- All web services should sit behind NGINX where possible.
- Maximize logical and physical separation of concerns.
- SSL everywhere.
- Secure public access via Cloudflare.
- Embrace automation.
- Adopt Infrastructure as Code.
- Avoid using `:latest` tags in Docker containers.

---

## Goals

### 📘 Document Home Setup
- Configuration
- Architecture
- Toolchain
- Simplify complexity
- Standardise
- Migrate to Infrastructure as Code

### ⚙️ Automate Deployments
- Allow for rapid rebuilds
- Support test environment deployments before production
- Improve flexibility

### 🔄 Automate Updates
- OS patching
- Router firmware updates
- Container updates (with testing)

### 🆕 New Capabilities
- Configuration storage for all tools and services
- Reliable backups
- Investigate moving to Kubernetes (future hardware permitting)