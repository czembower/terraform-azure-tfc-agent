resource "tfe_workspace" "this" {
  name                = "this-workspace"
  organization        = var.tfc_organization
  agent_pool_id       = tfe_agent_pool.this.id
  execution_mode      = "agent"
  working_directory   = "/"

  vcs_repo {
    identifier     = var.repo_path
    branch         = var.tfc_vcs_branch
    oauth_token_id = var.vcs_oauth_token_id
  }

  lifecycle {
    ignore_changes = [
      vcs_repo
    ]
  }
}

resource "tfe_variable" "this" {
  key          = "coolVar"
  value        = var.coolVar
  sensitive    = true
  category     = "terraform"
  workspace_id = tfe_workspace.this.id
}
