module "team_resources" {
  for_each = var.teams
  source   = "./modules/team_resources"

  team_name           = each.key
  grafana_team_name   = try(each.value.grafana_team_name, null)
  notification_emails = each.value.notification_emails
  irm_enabled         = each.value.irm_enabled
  oncall_route_type   = try(each.value.oncall_route.routing_type, null)
  oncall_route_regex  = try(each.value.oncall_route.routing_regex, null)
  oncall_route_pos    = try(each.value.oncall_route.position, null)

  providers = {
    grafana = grafana
  }
}

module "notification_routing" {
  source = "./modules/notification_routing"

  teams                       = var.teams
  default_notification_emails = var.default_notification_emails
  contact_point_names = {
    for team_name, team_module in module.team_resources :
    team_name => team_module.contact_point_name
  }

  providers = {
    grafana = grafana
  }
}
