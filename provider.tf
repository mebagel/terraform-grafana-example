
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.35"
    }
  }
}

provider "grafana" {
  url        = var.grafana_url
  oncall_url = var.grafana_oncall_url

  # Single service account token used for both core Grafana and OnCall APIs
  auth                = var.grafana_service_account_token
  oncall_access_token = var.grafana_service_account_token
}
