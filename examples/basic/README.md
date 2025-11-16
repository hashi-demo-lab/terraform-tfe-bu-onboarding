# BU Onboarding - Basic Example

**IMPORTANT**: This module is designed to run **INSIDE a BU Stack repository** created by the platform-onboarding module. It is NOT meant to be used standalone.

## Overview

This example demonstrates minimal workspace creation within a BU Stack that was automatically created by the platform team.

## How This Works

```
Platform Team runs platform-onboarding module
  ↓
Creates BU_platform-engineering project
  ↓
Creates GitHub repo: tfc-platform-engineering-bu-stack
  ↓
Seeds repo with Stack configuration (including this module)
  ↓
Creates HCP Terraform Stack connected to GitHub repo
  ↓
Platform Engineering team clones repo
  ↓
Updates configs/platform-engineering.yaml
  ↓
Commits and pushes changes
  ↓
Stack automatically runs (VCS-triggered)
  ↓
bu-onboarding module creates workspaces
```

## Features

- ✅ Single workspace creation
- ✅ Basic variable configuration  
- ✅ VCS integration with GitHub
- ✅ Auto-tagging with environment and business unit

## Prerequisites

1. **Platform Stack deployed** - Platform team has created your BU infrastructure
2. **GitHub repo exists** - `tfc-platform-engineering-bu-stack` repository created and seeded
3. **HCP Terraform Stack created** - Stack connected to your GitHub repo
4. **Repo cloned locally** - You have cloned the BU Stack repository

## Usage

### 1. Navigate to Your BU Stack Repository

```bash
cd tfc-platform-engineering-bu-stack
```

### 2. Edit Workspace Configuration

Edit `configs/platform-engineering.yaml`:

```yaml
business_unit: platform-engineering

workspaces:
  - workspace_name: k8s-dev-us-east-1
    workspace_description: Kubernetes development cluster in us-east-1
    workspace_terraform_version: "1.13.5"
    workspace_auto_apply: true
    workspace_tags:
      - kubernetes
      - development
    
    vcs_repo:
      identifier: hashi-demo-lab/kubernetes-platform
      branch: develop
    
    variables:
      - key: environment
        value: development
      - key: aws_region
        value: us-east-1
      - key: cluster_version
        value: "1.28"
      - key: node_count
        value: "3"
      - key: enable_monitoring
        value: "true"
        hcl: true
```

### 3. Commit and Push Changes

```bash
git add configs/platform-engineering.yaml
git commit -m "Add development Kubernetes workspace"
git push origin main
```

### 4. Stack Automatically Runs

The HCP Terraform Stack is VCS-connected and will automatically:
1. Detect your commit
2. Run a plan
3. Show you the workspace that will be created
4. Apply (after approval in HCP Terraform UI)

## What Gets Created

### TFE Resources
- **Workspace**: `k8s-dev-us-east-1` in project `BU_platform-engineering`
  - Terraform version: `1.13.5`
  - Auto-apply: enabled
  - VCS connected: `hashi-demo-lab/kubernetes-platform` (branch: `develop`)
  - Variables: environment, aws_region, cluster_version, node_count, enable_monitoring
  - Tags: kubernetes, development, environment:dev, business_unit:platform-engineering

## Verify Workspace Creation

1. **Check HCP Terraform UI**:
   ```
   https://app.terraform.io/app/cloudbrokeraz/projects/BU_platform-engineering
   ```

2. **View Stack Run**:
   ```
   https://app.terraform.io/app/cloudbrokeraz/projects/BU_platform-engineering/stacks/platform-engineering-bu-stack
   ```

3. **Find Your Workspace**:
   ```
   https://app.terraform.io/app/cloudbrokeraz/workspaces/k8s-dev-us-east-1
   ```

## Next Steps

1. **Trigger Workspace Run**: Queue a run in the newly created workspace to deploy infrastructure
2. **Add More Workspaces**: Edit YAML to add staging/production workspaces
3. **Configure Variables**: Add more variables or variable sets as needed

## Troubleshooting

### "Stack didn't run after push"
- Verify Stack is VCS-connected in HCP Terraform UI
- Check webhook configuration in GitHub repository settings
- Ensure changes are on the correct branch (main)

### "Workspace already exists"
- Check if workspace name is unique within the organization
- Workspace may have been created by a previous run

### "Invalid VCS repository"
- Ensure repository exists: `hashi-demo-lab/kubernetes-platform`
- Verify VCS OAuth token has access to the repository
- Check repository identifier format: `org/repo`

## Configuration Files

This example is meant to be used from within your seeded BU Stack repository which includes:
- `README.md` - BU-specific documentation
- `variables.tfcomponent.hcl` - Stack input variables
- `providers.tfcomponent.hcl` - TFE provider configuration
- `components.tfcomponent.hcl` - Component using bu-onboarding module
- `outputs.tfcomponent.hcl` - Stack outputs
- `deployments.tfdeploy.hcl` - Deployment definitions (dev/staging/prod)
- `configs/platform-engineering.yaml` - Workspace configuration (this file)

