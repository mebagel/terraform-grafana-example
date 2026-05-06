variable "grafana_url" {
  type        = string
  description = "Grafana Cloud stack URL"
}


variable "grafana_oncall_url" {
  type        = string
  description = "Grafana Cloud OnCall API base URL"
}

variable "grafana_service_account_token" {
  type      = string
  sensitive = true
}

variable "teams" {
  type = map(object({
    notification_emails = list(string)
    grafana_team_name   = optional(string)
    irm_enabled         = optional(bool, false)
    notification_policy = optional(object({
      continue        = optional(bool)
      group_by        = optional(list(string))
      group_wait      = optional(string)
      group_interval  = optional(string)
      repeat_interval = optional(string)
      matchers = optional(list(object({
        label = string
        match = string
        value = string
      })))
    }))
  }))
  description = "Map of teams and their per-team notification settings"

  validation {
    condition     = length(var.teams) > 0
    error_message = "Define at least one team."
  }

  validation {
    condition = alltrue([
      for team in values(var.teams) : length(team.notification_emails) > 0
    ])
    error_message = "Each team must define at least one notification email recipient."
  }

  validation {
    condition = alltrue([
      for team_name, team in var.teams : alltrue([
        for matcher in try(team.notification_policy.matchers, []) :
        (matcher.label == "team" && matcher.match == "=") ? matcher.value == team_name : true
      ])
    ])
    error_message = "If a matcher uses label=team with match==, its value must equal the team key."
  }
}

variable "default_notification_emails" {
  type        = list(string)
  default     = null
  nullable    = true
  description = "Fallback email recipients for alerts that do not match a team policy. If null, the first team's recipients in key order are used."

  validation {
    condition     = var.default_notification_emails == null || length(var.default_notification_emails) > 0
    error_message = "If provided, default_notification_emails must contain at least one recipient."
  }
}
