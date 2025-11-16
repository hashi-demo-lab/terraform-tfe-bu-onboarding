# BU Onboarding - Complete Example

This example demonstrates advanced usage of the bu-onboarding module with all features.

## Features

- ✅ Multiple workspaces (dev/staging/prod)
- ✅ VCS integration with different branches
- ✅ Variable sets (shared and workspace-specific)
- ✅ HCL variables (lists, maps, booleans)
- ✅ Sensitive variables
- ✅ Environment variables
- ✅ Terraform Cloud Agents (optional)
- ✅ Auto-apply configuration
- ✅ Structured run tasks

## Architecture

```
BU Stack (Finance)
  │
  ├─ Upstream Input: platform_stack
  │  └─ Provides: bu_project_id, tfc_organization_name, vcs_oauth_token_id
  │
  └─ Component: bu-onboarding
     ├─ Creates: 6 workspaces across 3 projects
     ├─ Creates: 2 variable sets (shared_config, database_credentials)
     └─ Configures: VCS, variables, auto-apply, agents
```

## Prerequisites

1. **Platform Stack deployed** - Must have BU infrastructure created
2. **OIDC configured** - For BU-specific audience
3. **VCS repositories** - GitHub repos with Terraform code
4. **TFC Agents** (optional) - If using agent execution mode

## Usage

### 1. Configure Advanced YAML

Edit `config/finance.yaml` with multiple workspaces:

```yaml
workspaces:
  # Development environment
  - name: payment-gateway-dev
    description: Payment gateway - development
    project_name: BU_finance__payment-gateway
    execution_mode: remote
    terraform_version: "1.13.5"
    auto_apply: true
    vcs_repo:
      identifier: CloudbrokerAz/payment-gateway
      branch: develop
    variables:
      - key: environment
        value: development
      - key: aws_region
        value: us-east-1
      - key: instance_count
        value: "1"
      - key: enable_monitoring
        value: "true"
        hcl: true
    environment_variables:
      - key: AWS_DEFAULT_REGION
        value: us-east-1

  # Staging environment
  - name: payment-gateway-staging
    description: Payment gateway - staging
    project_name: BU_finance__payment-gateway
    execution_mode: remote
    terraform_version: "1.13.5"
    vcs_repo:
      identifier: CloudbrokerAz/payment-gateway
      branch: staging
    variables:
      - key: environment
        value: staging
      - key: aws_region
        value: us-east-1
      - key: instance_count
        value: "2"
      - key: enable_monitoring
        value: "true"
        hcl: true

  # Production environment
  - name: payment-gateway-prod
    description: Payment gateway - production
    project_name: BU_finance__payment-gateway
    execution_mode: remote
    terraform_version: "1.13.5"
    vcs_repo:
      identifier: CloudbrokerAz/payment-gateway
      branch: main
    variables:
      - key: environment
        value: production
      - key: aws_region
        value: us-east-1
      - key: instance_count
        value: "5"
      - key: enable_monitoring
        value: "true"
        hcl: true
      - key: enable_high_availability
        value: "true"
        hcl: true

variable_sets:
  - name: shared_config
    description: Shared configuration for all finance workspaces
    global: false
    variables:
      - key: organization_name
        value: cloudbrokeraz
      - key: cost_center
        value: finance
      - key: compliance_tags
        value: '{"pci-dss": "required", "sox": "compliant"}'
        hcl: true
      - key: allowed_regions
        value: '["us-east-1", "us-west-2"]'
        hcl: true
    environment_variables:
      - key: TF_LOG
        value: INFO

  - name: database_credentials
    description: Database connection credentials
    global: false
    variables:
      - key: database_host
        value: finance-db.example.com
      - key: database_port
        value: "5432"
      - key: database_name
        value: finance_prod
      - key: database_password
        value: super-secret-password
        sensitive: true
        description: Production database password
```

### 2. Deploy

```bash
# Initialize and validate
terraform stacks providers-lock
terraform stacks validate

# Plan each deployment
terraform stacks plan --deployment=dev
terraform stacks plan --deployment=staging
terraform stacks plan --deployment=prod

# Apply via HCP Terraform UI
```

## What Gets Created

### Workspaces (6 total)
1. **payment-gateway-dev** (BU_finance__payment-gateway)
   - Auto-apply enabled
   - VCS: `CloudbrokerAz/payment-gateway` (branch: `develop`)
   - Instance count: 1

2. **payment-gateway-staging** (BU_finance__payment-gateway)
   - Manual apply
   - VCS: `CloudbrokerAz/payment-gateway` (branch: `staging`)
   - Instance count: 2

3. **payment-gateway-prod** (BU_finance__payment-gateway)
   - Manual apply
   - VCS: `CloudbrokerAz/payment-gateway` (branch: `main`)
   - Instance count: 5
   - High availability enabled

4. **reporting-dev** (BU_finance__financial-reporting)
5. **reporting-staging** (BU_finance__financial-reporting)
6. **reporting-prod** (BU_finance__financial-reporting)

### Variable Sets (2 total)
1. **shared_config** - Shared across all workspaces
   - Organization name, cost center, compliance tags
   - Environment variable: `TF_LOG=INFO`

2. **database_credentials** - Database connection info
   - Host, port, database name
   - Sensitive password (encrypted)

## Configuration Files

This example includes:
- [`README.md`](README.md) - This file
- [`config/finance.yaml`](config/finance.yaml) - Complete workspace configuration with all features
- Stack configuration files (pre-seeded by platform):
  - `variables.tfcomponent.hcl`
  - `providers.tfcomponent.hcl`
  - `components.tfcomponent.hcl`
  - `outputs.tfcomponent.hcl`
  - `deployments.tfdeploy.hcl`

## Advanced Features

### Using TFC Agents

```yaml
workspaces:
  - name: secure-workspace
    execution_mode: agent
    agent_pool_id: apool-xxxxx  # Get from platform outputs
    # ... other config
```

### Sensitive Variables

```yaml
variables:
  - key: api_secret
    value: my-secret-value
    sensitive: true
    description: API authentication secret
```

### HCL Variables

```yaml
variables:
  # Boolean
  - key: enable_feature
    value: "true"
    hcl: true

  # List
  - key: allowed_ips
    value: '["10.0.0.0/8", "172.16.0.0/12"]'
    hcl: true

  # Map
  - key: tags
    value: '{"Environment": "production", "Team": "finance"}'
    hcl: true
```

### Environment Variables

```yaml
environment_variables:
  - key: AWS_DEFAULT_REGION
    value: us-east-1
  - key: TF_LOG
    value: DEBUG
```

## Outputs

```hcl
# Workspace IDs
workspace_ids_map = {
  "payment-gateway-dev"     = "ws-dev-xxxxx"
  "payment-gateway-staging" = "ws-staging-xxxxx"
  "payment-gateway-prod"    = "ws-prod-xxxxx"
  "reporting-dev"           = "ws-rep-dev-xxxxx"
  "reporting-staging"       = "ws-rep-staging-xxxxx"
  "reporting-prod"          = "ws-rep-prod-xxxxx"
}

# Variable sets
variable_set_ids = {
  "shared_config"         = "varset-xxxxx"
  "database_credentials"  = "varset-yyyyy"
}

# Deployment summary
deployment_summary = {
  total_workspaces    = 6
  total_variable_sets = 2
  workspaces = [
    {
      name         = "payment-gateway-dev"
      id           = "ws-dev-xxxxx"
      project_name = "BU_finance__payment-gateway"
      auto_apply   = true
    },
    # ... more workspaces
  ]
}
```

## Verification

1. **Check Workspaces**:
   ```bash
   # Via HCP Terraform
   https://app.terraform.io/app/cloudbrokeraz/workspaces
   
   # Filter by project: BU_finance__payment-gateway
   ```

2. **Check Variable Sets**:
   ```bash
   https://app.terraform.io/app/cloudbrokeraz/settings/varsets
   ```

3. **Verify VCS Connection**:
   ```bash
   # Trigger run by pushing to VCS branch
   git push origin develop
   ```

4. **Check Outputs**:
   ```bash
   terraform stacks output --deployment=dev
   ```

## Best Practices

1. **Workspace Naming**: Use `<app>-<env>` pattern (e.g., `payment-gateway-prod`)
2. **Branch Strategy**: `develop` → `staging` → `main` for progressive deployment
3. **Auto-Apply**: Enable only for dev environments
4. **Sensitive Data**: Always mark secrets as `sensitive: true`
5. **Variable Sets**: Use for shared configuration across workspaces
6. **HCL Variables**: Use `hcl: true` for complex types (lists, maps, booleans)
7. **Project Organization**: Group related workspaces in same consumer project

## Troubleshooting

### "Workspace already exists"
Check if workspace name is unique within the organization.

### "Invalid variable value"
For HCL variables, ensure valid JSON syntax and set `hcl: true`.

### "VCS connection failed"
Verify GitHub repository exists and VCS OAuth token has access.

### "Variable set not found"
Ensure variable set name matches exactly (case-sensitive).

## Next Steps

1. **Monitor Runs**: Check run status in HCP Terraform UI
2. **Configure Notifications**: Set up Slack/email notifications for run results
3. **Add Run Tasks**: Configure policy checks, cost estimation
4. **Scale Workspaces**: Add more environments or applications as needed
