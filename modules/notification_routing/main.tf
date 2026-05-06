terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}

locals {
  default_team_notification_policy = {
    continue        = false
    group_by        = ["alertname", "team"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "4h"
  }

  team_notification_policies = {
    for team_name, team in var.teams :
    team_name => merge(
      local.default_team_notification_policy,
      try(team.notification_policy, {}),
      {
        matchers = coalescelist(try(team.notification_policy.matchers, []), [
          {
            label = "team"
            match = "="
            value = team_name
          }
        ])
      }
    )
  }

  default_notification_email = coalesce(
    var.default_notification_emails,
    var.teams[sort(keys(var.teams))[0]].notification_emails
  )
}

resource "grafana_contact_point" "default_email" {
  name = "default-email-contact-point"

  email {
    addresses    = local.default_notification_email
    single_email = true
  }
}

resource "grafana_notification_policy" "team_routing" {
  contact_point = grafana_contact_point.default_email.name
  group_by      = local.default_team_notification_policy.group_by

  dynamic "policy" {
    for_each = local.team_notification_policies

    content {
      contact_point = var.contact_point_names[policy.key]

      continue        = policy.value.continue
      group_by        = policy.value.group_by
      group_wait      = policy.value.group_wait
      group_interval  = policy.value.group_interval
      repeat_interval = policy.value.repeat_interval

      dynamic "matcher" {
        for_each = policy.value.matchers

        content {
          label = matcher.value.label
          match = matcher.value.match
          value = matcher.value.value
        }
      }
    }
  }
}