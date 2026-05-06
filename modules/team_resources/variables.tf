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

variable "oncall_route_type" {
  type     = string
  default  = null
  nullable = true
}

variable "oncall_route_regex" {
  type     = string
  default  = null
  nullable = true
}

variable "oncall_route_pos" {
  type     = number
  default  = null
  nullable = true
}
