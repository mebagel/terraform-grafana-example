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
}

variable "default_notification_emails" {
  type     = list(string)
  default  = null
  nullable = true
}

variable "contact_point_names" {
  type = map(string)
}