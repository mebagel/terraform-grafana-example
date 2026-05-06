# Terraform Grafana Team Provisioning

This project provisions team-scoped Grafana resources with optional IRM (OnCall):

- One Grafana folder per team
- Folder permissions per team
- One dedicated email contact point per team
- Central notification policy tree with one branch per team
- Optional OnCall resources per team (integration, schedule, escalation chain, route)

## Terraform Ownership

Terraform is the sole owner of the resources managed here, especially:

- Alerting contact points
- Notification policies
- Team folders and permissions
- OnCall resources for teams where `irm_enabled = true`

Avoid manual UI edits on these managed resources, otherwise drift/conflicts can occur.

## Sensitive Data Handling

- Use `teams.tfvars.example` as a template.
- Keep local `teams.tfvars` untracked.
- Prefer env var for token:

```bash
export TF_VAR_grafana_service_account_token="<your-token>"
```

## Setup

1. Create local vars file from template:

```bash
cp teams.tfvars.example teams.tfvars
```

2. Update `teams.tfvars` with your stack/team values.

3. Initialize and validate:

```bash
terraform init -upgrade
terraform validate
```

4. Plan and apply:

```bash
terraform plan -var-file=teams.tfvars
terraform apply -var-file=teams.tfvars
```

## Team Configuration Schema

Each team entry supports:

- `notification_emails` (required): list of email recipients
- `grafana_team_name` (optional): explicit Grafana team lookup name
- `irm_enabled` (optional, default `false`): enable OnCall resources
- `notification_policy` (optional): routing policy branch overrides
- `oncall_route` (optional): per-team OnCall route behavior

`oncall_route` fields:

- `routing_type` (optional): one of `jinja2`, `regex`, `content_based`
- `routing_regex` (optional): route expression/pattern used by Grafana OnCall
- `position` (optional): route order position

If omitted, defaults are:

- `routing_type = "jinja2"`
- `routing_regex = {{ payload.groupLabels.env == "prod" }}`
- `position = 0`

## Operational Notes

- If migrating pre-existing resources, import them before first apply.
- If you encounter stale lock issues, ensure no Terraform process is running before unlocking.
- If a legacy resource should remain in Grafana but not in Terraform, use `terraform state rm <address>`.
