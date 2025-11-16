# BU Onboarding - Complete Example

**This example demonstrates how to use the bu-onboarding module INSIDE a BU Stack repository.**

## Important: How This Works

This module is **NOT used standalone**. It runs inside a BU Stack that was created by the platform-onboarding module:

```
Platform Stack (Platform Team)
  ↓ creates
BU Control Project + GitHub Repo + HCP Stack
  ↓ BU team clones repo
tfc-platform-engineering-bu-stack (this repo)
  ↓ contains component
bu-onboarding module
  ↓ creates
Workspaces in BU projects
```

## Features

- ✅ Multiple workspaces (dev/staging/prod)
- ✅ VCS integration with different branches
- ✅ Multi-project workspace organization
- ✅ HCL variables (lists, maps, booleans)
- ✅ Sensitive variables
- ✅ Workspace-level variables
- ✅ Auto-apply for dev environments
- ✅ YAML-driven configuration

## Architecture

**BU Stack (Platform Engineering Team)** - runs in `BU_platform-engineering` project

The platform team created:
- ✅ Control project: `BU_platform-engineering`
- ✅ Consumer projects: `plat-eng_kubernetes-platform`, `plat-eng_service-mesh`, `plat-eng_ci-cd-platform`
- ✅ GitHub repository: `tfc-platform-engineering-bu-stack` (with seeded Stack config)
- ✅ HCP Terraform Stack (connected to GitHub repo)

Your BU team now manages workspaces by:
1. Editing `configs/platform-engineering.yaml` 
2. Committing changes to GitHub
3. Stack automatically runs and creates/updates workspaces

## Prerequisites

1. **Platform Stack deployed** - Platform team has created your BU infrastructure
2. **GitHub repo access** - You have access to `tfc-platform-engineering-bu-stack` repo
3. **VCS repositories** - Your application repos exist in GitHub (e.g., `kubernetes-platform`, `service-mesh`)
4. **BU Admin team member** - You're in the `platform-engineering_admin` team

## Usage Workflow

### 1. Clone Your BU Stack Repository

```bash
git clone git@github.com:hashi-demo-lab/tfc-platform-engineering-bu-stack.git
cd tfc-platform-engineering-bu-stack
```

### 2. Review the Seeded Configuration

The platform team already created these files:
- `variables.tfcomponent.hcl` - Stack variables
- `providers.tfcomponent.hcl` - Provider configuration  
- `components.tfcomponent.hcl` - **bu-onboarding module component**
- `outputs.tfcomponent.hcl` - Stack outputs
- `deployments.tfdeploy.hcl` - Dev/staging/prod deployments with upstream_input
- `configs/platform-engineering.yaml` - **Your workspace configuration**

### 3. Edit Workspace Configuration

Update `configs/platform-engineering.yaml` to define your workspaces:

```yaml
business_unit: platform-engineering

workspaces:
  # Kubernetes Development
  - workspace_name: k8s-dev-us-east-1
    workspace_description: Kubernetes cluster - development environment
    workspace_terraform_version: "1.13.5"
    workspace_auto_apply: true
    workspace_vcs_directory: terraform/kubernetes
    workspace_tags:
      - kubernetes
      - development
      - us-east-1
    
    vcs_repo:
      identifier: hashi-demo-lab/kubernetes-platform
      branch: develop
    
    variables:
      environment:
        value: development
        description: Deployment environment
      
      aws_region:
        value: us-east-1
        description: AWS region for deployment
      
      cluster_version:
        value: "1.28"
        description: Kubernetes version
      
      node_count:
        value: "3"
        description: Number of worker nodes
      
      enable_monitoring:
        value: "true"
        hcl: true
        description: Enable cluster monitoring

  # Kubernetes Staging
  - workspace_name: k8s-staging-us-east-1
    workspace_description: Kubernetes cluster - staging environment
    workspace_terraform_version: "1.13.5"
    workspace_auto_apply: false
    workspace_vcs_directory: terraform/kubernetes
    workspace_tags:
      - kubernetes
      - staging
    
    vcs_repo:
      identifier: hashi-demo-lab/kubernetes-platform
      branch: staging
    
    variables:
      environment:
        value: staging
      aws_region:
        value: us-east-1
      cluster_version:
        value: "1.28"
      node_count:
        value: "5"
      enable_monitoring:
        value: "true"
        hcl: true

  # Kubernetes Production
  - workspace_name: k8s-prod-us-east-1
    workspace_description: Kubernetes cluster - production environment
    workspace_terraform_version: "1.13.5"
    workspace_auto_apply: false
    workspace_vcs_directory: terraform/kubernetes
    workspace_tags:
      - kubernetes
      - production
      - critical
    
    vcs_repo:
      identifier: hashi-demo-lab/kubernetes-platform
      branch: main
    
    variables:
      environment:
        value: production
      aws_region:
        value: us-east-1
      cluster_version:
        value: "1.28"
      node_count:
        value: "10"
      enable_monitoring:
        value: "true"
        hcl: true
      enable_high_availability:
        value: "true"
        hcl: true
        description: Enable HA configuration

  # Service Mesh Production
  - workspace_name: service-mesh-prod
    workspace_description: Istio service mesh - production
    workspace_terraform_version: "1.13.5"
    workspace_auto_apply: false
    workspace_tags:
      - service-mesh
      - istio
      - production
    
    vcs_repo:
      identifier: hashi-demo-lab/service-mesh
      branch: main
    
    variables:
      environment:
        value: production
      mesh_type:
        value: istio
        description: Service mesh implementation
      enable_tracing:
        value: "true"
        hcl: true
        description: Enable distributed tracing
      enable_mtls:
        value: "true"
        hcl: true
        description: Enable mutual TLS
```

### 4. Commit and Push Changes

```bash
git add configs/platform-engineering.yaml
git commit -m "Add Kubernetes and service mesh workspaces"
git push origin main
```

### 5. Stack Automatically Runs

When you push to GitHub:
1. **HCP Terraform Stack detects the commit** (VCS-connected)
2. **Stack runs automatically** in the `BU_platform-engineering` project
3. **bu-onboarding module executes** (reads your YAML)
4. **Workspaces are created** in the consumer projects

### 6. Monitor the Stack Run

```bash
# View in HCP Terraform UI
https://app.terraform.io/app/cloudbrokeraz/projects/BU_platform-engineering/stacks/platform-engineering-bu-stack
```

## What Gets Created

### Workspaces (4 total in this example)

1. **k8s-dev-us-east-1** (`plat-eng_kubernetes-platform` project)
   - Auto-apply: ✅ Enabled
   - VCS: `hashi-demo-lab/kubernetes-platform` (branch: `develop`)
   - Node count: 3
   - Tags: `kubernetes`, `development`, `us-east-1`, `environment:dev`, `business_unit:platform-engineering`

2. **k8s-staging-us-east-1** (`plat-eng_kubernetes-platform` project)
   - Auto-apply: ❌ Manual
   - VCS: `hashi-demo-lab/kubernetes-platform` (branch: `staging`)
   - Node count: 5
   - Tags: `kubernetes`, `staging`, `environment:staging`, `business_unit:platform-engineering`

3. **k8s-prod-us-east-1** (`plat-eng_kubernetes-platform` project)
   - Auto-apply: ❌ Manual
   - VCS: `hashi-demo-lab/kubernetes-platform` (branch: `main`)
   - Node count: 10
   - High availability: ✅ Enabled
   - Tags: `kubernetes`, `production`, `critical`, `environment:production`, `business_unit:platform-engineering`

4. **service-mesh-prod** (`plat-eng_service-mesh` project)
   - Auto-apply: ❌ Manual
   - VCS: `hashi-demo-lab/service-mesh` (branch: `main`)
   - Mesh type: Istio
   - mTLS: ✅ Enabled
   - Tracing: ✅ Enabled
   - Tags: `service-mesh`, `istio`, `production`, `environment:production`, `business_unit:platform-engineering`

**Note:** Tags `environment:{env}` and `business_unit:{bu}` are automatically added by the module!

## Configuration Files in BU Stack Repo

The seeded repository contains:

- **`README.md`** - BU-specific documentation
- **`variables.tfcomponent.hcl`** - Stack input variables (upstream inputs, YAML config)
- **`providers.tfcomponent.hcl`** - TFE provider with authentication
- **`components.tfcomponent.hcl`** - Component sourcing bu-onboarding module from PMR
- **`outputs.tfcomponent.hcl`** - Stack outputs (workspace maps, deployment summary)
- **`deployments.tfdeploy.hcl`** - Dev/staging/prod deployments with `upstream_input` from platform stack
- **`configs/platform-engineering.yaml`** - Your workspace configuration (edit this!)
- **`.github/workflows/terraform-stacks.yml`** - CI/CD workflow (optional)

## Advanced YAML Features

### Sensitive Variables

```yaml
variables:
  api_secret:
    value: my-secret-value
    sensitive: true
    description: API authentication secret
```

### HCL Variables (Complex Types)

```yaml
variables:
  # Boolean
  enable_feature:
    value: "true"
    hcl: true

  # List
  allowed_ips:
    value: '["10.0.0.0/8", "172.16.0.0/12"]'
    hcl: true
    description: Allowed IP ranges

  # Map/Object
  tags:
    value: '{"Environment": "production", "Team": "platform-engineering", "CostCenter": "engineering"}'
    hcl: true
    description: Resource tags
```

### Multiple Workspaces Per Project

```yaml
workspaces:
  - workspace_name: k8s-dev-us-east-1
    # ... config
  
  - workspace_name: k8s-dev-eu-west-1
    # ... config (same project, different region)
```

### Working Directory Configuration

```yaml
workspaces:
  - workspace_name: networking-prod
    workspace_vcs_directory: terraform/networking  # Subdirectory in repo
    vcs_repo:
      identifier: hashi-demo-lab/infrastructure
      branch: main
```

## Stack Outputs

After the Stack runs successfully, you'll see outputs:

```hcl
# Workspace IDs mapping
workspace_ids_map = {
  "k8s-dev-us-east-1"      = "ws-abc123"
  "k8s-staging-us-east-1"  = "ws-def456"
  "k8s-prod-us-east-1"     = "ws-ghi789"
  "service-mesh-prod"      = "ws-jkl012"
}

# Workspace URLs
workspace_urls = {
  "k8s-dev-us-east-1" = "https://app.terraform.io/app/cloudbrokeraz/workspaces/k8s-dev-us-east-1"
  # ... more
}

# Deployment summary
deployment_summary = {
  business_unit    = "platform-engineering"
  environment      = "production"
  workspaces_count = 4
  created_at       = "2024-11-17T..."
}
```

## Verification Steps

### 1. Check Stack Run Status

```bash
# Via UI
https://app.terraform.io/app/cloudbrokeraz/projects/BU_platform-engineering/stacks/platform-engineering-bu-stack

# Look for:
# - ✅ Plan succeeded
# - ✅ Apply succeeded
# - 📊 Deployments tab shows dev/staging/production
```

### 2. Verify Workspaces Created

```bash
# Via HCP Terraform UI
https://app.terraform.io/app/cloudbrokeraz/workspaces

# Filter by project: plat-eng_kubernetes-platform
# Should see: k8s-dev-us-east-1, k8s-staging-us-east-1, k8s-prod-us-east-1
```

### 3. Test VCS Connection

```bash
# Clone your application repo
git clone git@github.com:hashi-demo-lab/kubernetes-platform.git
cd kubernetes-platform
git checkout develop

# Make a change and push
echo "# Test" >> README.md
git add README.md
git commit -m "Test VCS trigger"
git push origin develop

# Check if workspace run triggered:
https://app.terraform.io/app/cloudbrokeraz/workspaces/k8s-dev-us-east-1/runs
```

### 4. Verify Auto-Apply Behavior

- **Dev workspace (k8s-dev)**: Should auto-apply after successful plan
- **Staging/Prod workspaces**: Should wait for manual approval

## Best Practices

### 1. Workspace Naming
Use clear, consistent patterns:
- `{service}-{env}-{region}`: `k8s-prod-us-east-1`
- `{app}-{env}`: `api-gateway-staging`
- `{function}-{env}`: `monitoring-dev`

### 2. Branch Strategy
Progressive promotion through environments:
```
develop → staging → main
   ↓         ↓        ↓
  dev     staging   prod
```

### 3. Auto-Apply Rules
- ✅ **Enable** for dev/sandbox environments
- ❌ **Disable** for staging/production (manual approval required)
- 📋 Review plans before applying to production

### 4. Variable Management
- Use `hcl: true` for complex types (lists, maps, booleans)
- Mark credentials as `sensitive: true`
- Document all variables with clear descriptions
- Use consistent naming (snake_case)

### 5. Tags
- Let module auto-add `environment` and `business_unit` tags
- Add custom tags for cost allocation, criticality, compliance
- Use tags for organization and filtering in HCP Terraform UI

### 6. Git Workflow
```bash
# Create feature branch
git checkout -b feature/add-monitoring-workspace

# Edit YAML
vim configs/platform-engineering.yaml

# Commit with descriptive message
git commit -m "Add monitoring workspace for prometheus stack"

# Push and create PR
git push origin feature/add-monitoring-workspace

# After review, merge to main
# Stack automatically runs on main branch
```

## Troubleshooting

### "This object does not have an attribute named 'workspace_name'"
**Cause**: YAML structure incorrect - missing `workspace_` prefix  
**Fix**: Ensure field names start with `workspace_`:
- ✅ `workspace_name`
- ✅ `workspace_description`
- ✅ `workspace_terraform_version`
- ❌ `name`, `description`, `terraform_version`

### "Workspace already exists"
**Cause**: Workspace name already used in organization  
**Fix**: Choose unique workspace names or delete existing workspace

### "VCS connection failed"
**Cause**: Repository doesn't exist or OAuth token lacks permissions  
**Fix**:
1. Verify repository exists: `https://github.com/hashi-demo-lab/kubernetes-platform`
2. Check OAuth token has access to the repository
3. Ensure branch name is correct (`main`, `develop`, etc.)

### "Invalid variable value for HCL type"
**Cause**: JSON syntax error in HCL variable value  
**Fix**: Validate JSON before setting:
```yaml
# ❌ Wrong (single quotes, unquoted keys)
value: '{enable: true}'

# ✅ Correct (double quotes, proper JSON)
value: '{"enable": true}'
hcl: true
```

### "Stack run failed - upstream_input not found"
**Cause**: Platform Stack hasn't published outputs yet  
**Fix**: Ensure platform Stack has run successfully first

### "Permission denied"
**Cause**: User not in BU admin team  
**Fix**: Platform team must add you to `platform-engineering_admin` team

## Next Steps

### 1. Add More Workspaces
Edit `configs/platform-engineering.yaml` to add:
- More environments (QA, UAT, DR)
- Additional regions (multi-region deployments)
- New applications (CI/CD platform, monitoring stack)

### 2. Organize Workspaces by Project
Group related workspaces in consumer projects:
- `plat-eng_kubernetes-platform`: All Kubernetes workspaces
- `plat-eng_service-mesh`: Service mesh workspaces
- `plat-eng_ci-cd-platform`: CI/CD pipeline workspaces

### 3. Configure Notifications
Set up notifications for workspace runs:
- Slack integration for run status
- Email notifications for failed applies
- Webhook integrations for custom workflows

### 4. Implement Run Tasks (Optional)
Add policy checks and validations:
- Cost estimation before applies
- Security scanning with Sentinel/OPA
- Compliance checks (PCI-DSS, SOC2, HIPAA)

### 5. Scale to Other BU Teams
Your BU's pattern can be replicated:
- Security Operations team: `tfc-security-ops-bu-stack`
- Cloud Infrastructure team: `tfc-cloud-infrastructure-bu-stack`
- Each team manages their own workspaces independently

## Related Resources

- **Platform Stack Repository**: Where platform team manages BU infrastructure
- **bu-onboarding Module**: [app.terraform.io/cloudbrokeraz/bu-onboarding/tfe](https://app.terraform.io/cloudbrokeraz/registry/modules/private/cloudbrokeraz/bu-onboarding/tfe)
- **Your BU Stack**: `https://github.com/hashi-demo-lab/tfc-platform-engineering-bu-stack`
- **HCP Terraform Stacks Docs**: [developer.hashicorp.com/terraform/language/stacks](https://developer.hashicorp.com/terraform/language/stacks)

---

**Example Version**: 2.0.0  
**Last Updated**: November 2024  
**BU**: Platform Engineering Team
