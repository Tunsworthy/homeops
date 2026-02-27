# Helper script to generate SSH keys for ansible-admin
# Run this once to create the key pair, then add to GitHub secrets

$ErrorActionPreference = "Stop"

$KeyName = "ansible-admin"
$KeyType = "ed25519"
$KeyPath = Join-Path $env:USERPROFILE ".ssh\$KeyName"
$Comment = "ansible-admin@homelab"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Generating SSH Key Pair for ansible-admin" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if key already exists
if (Test-Path $KeyPath) {
    Write-Host "⚠️  WARNING: Key already exists at $KeyPath" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
    Remove-Item $KeyPath, "$KeyPath.pub" -Force
}

# Ensure .ssh directory exists
$sshDir = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

# Generate the key
Write-Host "Generating $KeyType key pair..." -ForegroundColor Green
ssh-keygen -t $KeyType -f $KeyPath -N '""' -C $Comment

Write-Host ""
Write-Host "✅ Key pair generated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "GitHub Secret Configuration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these two secrets to your GitHub repository:" -ForegroundColor White
Write-Host "Settings → Secrets and variables → Actions → New repository secret" -ForegroundColor Gray
Write-Host ""
Write-Host "---" -ForegroundColor Yellow
Write-Host "Secret Name: SSH_ADMIN_PRIVATE_KEY" -ForegroundColor White
Write-Host "---" -ForegroundColor Yellow
Write-Host "Value (copy everything below):" -ForegroundColor Gray
Write-Host ""
Get-Content $KeyPath -Raw
Write-Host ""
Write-Host "---" -ForegroundColor Yellow
Write-Host "Secret Name: SSH_ADMIN_PUBLIC_KEY" -ForegroundColor White
Write-Host "---" -ForegroundColor Yellow
Write-Host "Value (copy everything below):" -ForegroundColor Gray
Write-Host ""
Get-Content "$KeyPath.pub"
Write-Host ""
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Private key: $KeyPath" -ForegroundColor White
Write-Host "Public key: $KeyPath.pub" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: Keep the private key secure!" -ForegroundColor Yellow
Write-Host "   Do NOT commit it to git or share publicly." -ForegroundColor Yellow
Write-Host ""
