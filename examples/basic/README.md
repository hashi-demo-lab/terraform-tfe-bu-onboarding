# BU Onboarding - Basic Example

This example demonstrates minimal usage of the bu-onboarding module within a BU Stack.

## Features

- ✅ Single workspace creation
- ✅ Basic variable configuration
- ✅ Uses upstream inputs from platform Stack
- ✅ Simple YAML configuration

## Architecture

```
BU Stack (Finance)
  │
  ├─ Upstream Input: platform_stack
  │  └─ Provides: bu_project_id, tfc_organization_name, vcs_oauth_token_id
  │
  └─ Component: bu-onboarding
     └─ Creates: 1 workspace in BU_finance project
```

## Prerequisites

1. **Platform Stack deployed** - Must have BU infrastructure created
2. **GitHub repo seeded** - This example assumes you're in a BU Stack repo created by platform
3. **OIDC configured** - For BU-specific audience (e.g., `finance-team-*`)

## Usage

### 1. Configure OIDC for BU

Set up OIDC trust relationship with BU-specific audience: `finance-team-*`

**AWS Trust Policy Example**:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/app.terraform.io"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "app.terraform.io:aud": "aws.workload.identity"
      },
      "StringLike": {
        "app.terraform.io:sub": "organization:cloudbrokeraz:project:BU_finance:*"
      }
    }
  }]
}
```

### 2. Create Workspace Configuration

Edit `config/finance.yaml`:

```yaml
workspaces:
  - name: web-app-dev
    description: Finance web application - development environment
    project_name: BU_finance__web-app
    execution_mode: remote
    terraform_version: "1.13.5"
    vcs_repo:
      identifier: CloudbrokerAz/finance-web-app
      branch: develop
    variables:
      - key: environment
        value: development
      - key: aws_region
        value: us-east-1
```

### 3. Deploy

```bash
# Initialize and validate
terraform stacks providers-lock
terraform stacks validate

# Plan deployment
terraform stacks plan --deployment=dev

# Apply via HCP Terraform UI
```

## What Gets Created

### TFE Resources
- **Workspace**: `web-app-dev` in project `BU_finance__web-app`
  - Terraform version: `1.13.5`
  - Execution mode: `remote`
  - VCS connected: `CloudbrokerAz/finance-web-app` (branch: `develop`)
  - Variables: `environment=development`, `aws_region=us-east-1`

## Configuration Files

This example includes:
- [`README.md`](README.md) - This file
- [`config/finance.yaml`](config/finance.yaml) - Workspace configuration
- Stack configuration files (pre-seeded by platform):
  - `variables.tfcomponent.hcl`
  - `providers.tfcomponent.hcl`
  - `components.tfcomponent.hcl`
  - `outputs.tfcomponent.hcl`
  - `deployments.tfdeploy.hcl`

## Outputs

```hcl
# Workspace information
workspace_ids_map = {
  "web-app-dev" = "ws-xxxxx"
}

# Deployment summary
deployment_summary = {
  total_workspaces = 1
  workspaces = [
    {
      name         = "web-app-dev"
      id           = "ws-xxxxx"
      project_name = "BU_finance__web-app"
    }
  ]
}
```

## Next Steps

1. **Verify Workspace**: Check HCP Terraform for created workspace
   ```
   https://app.terraform.io/app/cloudbrokeraz/workspaces/web-app-dev
   ```

2. **Run Terraform**: Trigger a run in the workspace to deploy infrastructure

3. **Add More Workspaces**: Edit `config/finance.yaml` to add staging/production workspaces

## Troubleshooting

### "Project not found"
Verify platform Stack has created the BU project. Check upstream_input is correct.

### "VCS OAuth token invalid"
Ensure platform Stack has shared VCS token correctly via upstream outputs.

### "Insufficient permissions"
Verify BU admin token is being used (from platform Stack outputs).
