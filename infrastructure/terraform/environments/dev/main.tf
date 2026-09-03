# =============================================================================
# Dev Environment — Root Module
# =============================================================================
# Scaffolding only. This root module is where the modules/* building blocks
# (foundation, data, containers, application, performance) will be wired
# together for the dev environment. No resources are provisioned yet — real
# module calls are added by Copilot coding agent via the agentic workflow,
# with PR review before merge.
#
# Example of what this will look like once authored (not active):
#
# module "foundation" {
#   source      = "../../modules/foundation"
#   environment = var.environment
#   location    = var.location
# }
#
# module "data" {
#   source              = "../../modules/data"
#   resource_group_name = module.foundation.resource_group_name
#   ...
# }
# =============================================================================
