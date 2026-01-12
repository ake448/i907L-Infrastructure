# Git Collaboration Setup Guide

This guide explains how to set up Git collaboration between you and your client for the Terraform infrastructure project.

## Prerequisites

- GitHub account (free)
- VS Code installed on client computer
- Git installed locally (will be installed if needed)

---

## Step 1: Create GitHub Repository

### For the Developer (You)

1. Go to [https://github.com](https://github.com)
2. Click **"New repository"**
3. Repository name: `i907L-terraform-infrastructure`
4. Make it **Private** (contains sensitive AWS config)
5. **Do NOT** initialize with README, .gitignore, or license
6. Click **"Create repository"**

Copy the repository URL shown on the next page:
```
https://github.com/YOUR_USERNAME/i907L-terraform-infrastructure.git
```

---

## Step 2: Push Current Code to Git

### On Your Computer (Windows PowerShell)

```powershell
# Navigate to your project folder
cd "C:\Users\ibuse\Downloads\i907L\i907L"

# Initialize Git repository
git init

# Create .gitignore to exclude sensitive files
@"
# Terraform state files
terraform.tfstate*
.terraform/

# SSH keys and sensitive files
*.pem
*.key
wireguard_keys.tfvars

# AWS credentials
.aws/

# OS files
.DS_Store
Thumbs.db
"@ | Out-File -FilePath .gitignore -Encoding UTF8

# Add all files
git add .

# Commit with descriptive message
git commit -m "Initial commit: Complete AWS infrastructure with 5 Windows servers and WireGuard VPN"

# Connect to GitHub repository (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/i907L-terraform-infrastructure.git

# Push to GitHub
git push -u origin main
```

**Expected Output:**
```
Enumerating objects: XX, done.
Counting objects: 100% (XX/XX), done.
...
To https://github.com/YOUR_USERNAME/i907L-terraform-infrastructure.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## Step 3: Client Setup with VS Code

### Instructions for Client

1. **Install Git** (if not already installed):
   - Windows: Download from [https://git-scm.com/download/win](https://git-scm.com/download/win)
   - macOS: `brew install git`
   - Linux: `sudo apt install git`

2. **Open VS Code**

3. **Clone the repository**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Git: Clone" and select it
   - Paste the repository URL:
     ```
     https://github.com/YOUR_USERNAME/i907L-terraform-infrastructure.git
     ```
   - Choose a folder to save the project
   - Click "Open" when prompted

4. **Verify setup**:
   - You should see all project files in VS Code Explorer
   - Look for green checkmarks indicating Git is working

---

## Step 4: Daily Workflow

### When You Make Changes (Developer)

```bash
# After editing files
git add .
git commit -m "Describe your changes here"
git push
```

### When Client Wants Latest Changes

**In VS Code:**
1. Click the **Source Control** icon (branch symbol) in left sidebar
2. Click the **"..."** menu (3 dots)
3. Select **"Pull"** (or press `Ctrl+Shift+P` → "Git: Pull")

**Or via terminal:**
```bash
git pull
```

### When Client Makes Changes

**In VS Code:**
1. Edit files as needed
2. Click **Source Control** icon
3. Click **+** next to changed files to stage them
4. Enter a commit message in the text box
5. Click the **✓** (check mark) to commit
6. Click **"..."** menu → **"Push"** to upload changes

### You Pull Client Changes

```bash
git pull
```

---

## Step 5: File Organization

The repository contains:

```
├── main.tf              # Provider configuration
├── network.tf           # VPC, subnets, gateways
├── ec2.tf              # Windows server instances
├── vpn.tf              # WireGuard VPN server
├── security.tf         # Security groups
├── outputs.tf          # Terraform outputs
├── variables.tf        # Input variables
├── terraform.tfvars    # Your AWS configuration
├── wireguard-init.sh   # VPN server setup script
├── wireguard-client.conf # VPN client configuration
└── *.md                # Documentation files
```

### Sensitive Files (NOT in Git)

- `terraform.tfstate*` - Contains actual resource IDs
- `*.pem` - SSH private keys
- `wireguard_keys.tfvars` - Generated VPN keys

These are excluded via `.gitignore`

---

## Step 6: Troubleshooting

### "Repository not found" Error
- Check the repository URL is correct
- Ensure repository is not private (or you have access)
- Verify your GitHub username in the URL

### "Permission denied" Error
- Make sure you have push access to the repository
- Check if repository is private and you're logged in

### VS Code Git Issues
- Click the **Source Control** icon
- Look for error messages in the panel
- Try **"Git: Fetch"** from command palette

### Merge Conflicts
- VS Code will highlight conflicted files
- Click "Accept Current Change", "Accept Incoming Change", or "Accept Both"
- Commit the resolved files

---

## Step 7: Best Practices

### Commit Messages
- Use clear, descriptive messages
- Example: `"Add DNS configuration to WireGuard server"`
- Not: `"fix stuff"`

### Branching (Optional)
```bash
# Create feature branch
git checkout -b feature/new-server

# Work on changes
git add .
git commit -m "Add new server configuration"

# Merge back to main
git checkout main
git merge feature/new-server
git push
```

### Regular Sync
- Pull changes before starting work
- Push changes when work is complete
- Communicate with client about major changes

---

## Contact

If you encounter issues:
1. Check the troubleshooting section above
2. Verify Git and VS Code are properly installed
3. Ensure repository URLs are correct
4. Check GitHub repository permissions

**Repository URL:** `https://github.com/YOUR_USERNAME/i907L-terraform-infrastructure.git`

---

*This setup enables real-time collaboration on your infrastructure code.*