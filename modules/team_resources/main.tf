terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}

locals {
  team              = lower(var.team_name)
  grafana_team_name = coalesce(var.grafana_team_name, local.team)
}

data "grafana_oncall_team" "team" {
  count = var.irm_enabled ? 1 : 0
  name  = local.grafana_team_name
}

data "grafana_team" "team" {
  name = local.grafana_team_name
}

resource "grafana_folder" "team" {
  title = "team-${local.team}"
}

resource "grafana_folder_permission" "team" {
  folder_uid = grafana_folder.team.uid

  permissions {
    role       = "Admin"
    permission = "Admin"
  }

  permissions {
    team_id    = tostring(data.grafana_team.team.team_id)
    permission = "Edit"
  }
}

resource "grafana_contact_point" "team" {
  name = "${local.team}-email-contact-point"

  email {
    addresses    = var.notification_emails
    single_email = true
  }
}

resource "grafana_oncall_integration" "team" {
  count   = var.irm_enabled ? 1 : 0
  name    = "${local.team}-integration"
  type    = "alertmanager"
  team_id = data.grafana_oncall_team.team[0].id

  default_route {
    escalation_chain_id = grafana_oncall_escalation_chain.team[0].id
  }
}

resource "grafana_oncall_schedule" "team" {
  count     = var.irm_enabled ? 1 : 0
  name      = "${local.team}-schedule"
  time_zone = "Europe/Zurich"
  type      = "calendar"
  team_id   = data.grafana_oncall_team.team[0].id
}

resource "grafana_oncall_escalation_chain" "team" {
  count   = var.irm_enabled ? 1 : 0
  name    = "${local.team}-escalation-chain"
  team_id = data.grafana_oncall_team.team[0].id
}

resource "grafana_oncall_escalation" "notify_schedule" {
  count                        = var.irm_enabled ? 1 : 0
  escalation_chain_id          = grafana_oncall_escalation_chain.team[0].id
  type                         = "notify_on_call_from_schedule"
  notify_on_call_from_schedule = grafana_oncall_schedule.team[0].id
  position                     = 0
}

resource "grafana_oncall_route" "team" {
  count               = var.irm_enabled ? 1 : 0
  integration_id      = grafana_oncall_integration.team[0].id
  escalation_chain_id = grafana_oncall_escalation_chain.team[0].id
  routing_type        = "jinja2"
  routing_regex       = <<EOT
{{ payload.groupLabels.env == "prod" }}
EOT
  position            = 0
}

output "contact_point_name" {
  value = grafana_contact_point.team.name
}
