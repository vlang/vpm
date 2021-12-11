module github

import time

[heap]
pub struct Installation {
pub:
	id                        i64
	node_id                   string
	app_id                    i64
	app_slug                  string
	target_id                 i64
	account                   &User
	access_tokens_url         string
	repositories_url          string
	html_url                  string
	target_type               string
	single_file_name          string
	repository_selection      string
	events                    []string
	single_file_paths         []string
	permissions               &InstallationPermissions
	created_at                time.Time
	updated_at                time.Time
	has_multiple_single_files bool
	suspended_by              &User
	suspended_at              time.Time
}

[heap]
pub struct InstallationPermissions {
pub:
	actions                          string
	administration                   string
	blocking                         string
	checks                           string
	contents                         string
	content_references               string
	deployments                      string
	emails                           string
	environments                     string
	followers                        string
	issues                           string
	metadata                         string
	members                          string
	organization_administration      string
	organization_hooks               string
	organization_plan                string
	organization_pre_receive_hooks   string
	organization_projects            string
	organization_secrets             string
	organization_self_hosted_runners string
	organization_user_blocking       string
	packages                         string
	pages                            string
	pull_requests                    string
	repository_hooks                 string
	repository_projects              string
	repository_pre_receive_hooks     string
	secrets                          string
	secret_scanning_alerts           string
	security_events                  string
	single_file                      string
	statuses                         string
	team_discussions                 string
	vulnerability_alerts             string
	workflows                        string
}
