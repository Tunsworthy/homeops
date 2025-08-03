1) Installed ubuntu via Pi imager
    1a) used to options to auto connect to the wifi, create local user
    1b) Added in public key to allow passwordless login ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRjIhIDVrQMJv74Xj9aB5f4+dthIDdzmk2blFDwAmWjbykP4eTK0DODXp8Q0mqiVt/G1k5ekCI0bT3KnkiY+7lkBe3X/KBfWvPMfI5iqRkoF8wfgXUJNEa2YhF4Gq+CStD2/zlr1u29PGN14ppnCIp0/AAkAjw3K5g1P3ukVfThWQEvD0LZk126zXb10ISc0lfrNW6moMzDdvDCDJrqol1WDzacxEPsGKtSwBUYHFTwSSzgZYxtex6kgfWPUBhQLFKJWWr/8bONU9R94q5lgGljRqdjml+6N2pgWyJuveI31ZMvcTdgoBa0jPzzREo2kzKev27L3YjeSVu4w6cyXsx rsa-key-20231005
2) Once booted created another user account for github runner
# 1. Create the user with no login shell and no home directory
sudo useradd --system --no-create-home --shell /usr/sbin/nologin runner

# 2. Set password on account
sudo passwd runner

# Deny SSH login in /etc/ssh/sshd_config
echo 'DenyUsers runner' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd

sudo mkdir -p /opt/github-runner
sudo chown runner: /opt/github-runner

# Switch to the install directory
cd /opt/github-runner

# Download and unpack GitHub runner (replace version as needed)
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
tar xzf actions-runner-linux-x64.tar.gz

# Configure the runner
sudo -u runner ./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN --unattended

# Install as a service
sudo ./svc.sh install runner
sudo ./svc.sh start

4) Allow runner to execute commands
sudo tee /etc/sudoers.d/runner <<'EOF'
runner ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt install *, /usr/bin/ansible, /usr/bin/ansible-playbook
EOF
sudo chmod 440 /etc/sudoers.d/runner
4) In github add the required tags (test)

5) Once runner is up you can run the Network workflow this will add the rquired VLANs

6) Run the docker setup script

##Things to do##
-Created docker installer ansible playbook
https://docs.docker.com/engine/install/linux-postinstall/