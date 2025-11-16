# ============================================================================
# YAML Configuration Processing
# ============================================================================

locals {
  # Parse YAML content passed from Stack deployment
  yaml_config = yamldecode(var.yaml_config_content)
  
  # Extract business unit identifier
  config_business_unit = try(local.yaml_config.business_unit, null)
  
  # Filter based on business_unit variable (if specified)
  process_this_config = var.business_unit == null || local.config_business_unit == var.business_unit
  
  # Extract workspaces list (only if business_unit matches)
  workspaces_raw = local.process_this_config ? try(local.yaml_config.workspaces, []) : []
  
  # Create map of workspaces indexed by workspace_name
  workspaces = {
    for idx, workspace in local.workspaces_raw :
    workspace.workspace_name => merge(workspace, {
      bu                = local.config_business_unit
      workspace_key     = workspace.workspace_name
      full_key          = "${local.config_business_unit}_${workspace.workspace_name}"
      # Add environment tag
      workspace_tags = concat(
        try(workspace.workspace_tags, []),
        ["environment:${var.environment}", "business_unit:${local.config_business_unit}"]
      )
    })
    if can(workspace.workspace_name)
  }
  
  # Extract variable sets configuration
  workspace_variable_sets_raw = flatten([
    for key, workspace in local.workspaces : [
      for varset in try(workspace.var_sets, []) : {
        workspace_name      = workspace.workspace_name
        organization        = var.tfc_organization_name
        create_variable_set = try(workspace.create_variable_set, false)
        var_sets            = varset
      }
    ] if try(workspace.create_variable_set, false)
  ])
  
  # Create map of variable sets indexed by variable_set_name
  variable_sets = {
    for varset in local.workspace_variable_sets_raw :
    varset.var_sets.variable_set_name => varset
  }
  
  # Summary counts
  workspaces_count = length(local.workspaces)
  var_sets_count   = length(local.variable_sets)
}
