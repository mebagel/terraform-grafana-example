variable "team_name" {
  type = string
}

variable "grafana_team_name" {
  type     = string
  default  = null
  nullable = true
}

variable "notification_emails" {
  type = list(string)
}

variable "irm_enabled" {
  type    = bool
  default = false
}
