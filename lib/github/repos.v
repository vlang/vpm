module github

import time
import x.json2
import lib.json2 as ju

pub struct License {
pub mut:
	key  string
	name string
	url  string

	spdx_id  string
	node_id  string
	html_url string
}

pub fn (mut l License) from_json(obj json2.Any) {
	ju.to(mut l, obj.as_map())
}

pub struct Permissions {
pub mut:
	admin    bool
	pull     bool
	triage   bool
	push     bool
	maintain bool
}

pub fn (mut p Permissions) from_json(obj json2.Any) {
	ju.to(mut p, obj.as_map())
}

// TODO: one or a few fields here are wrong, and when deserializing correct GitHub API response, it panics with error "V panic: array index out of range".
// Investigation and fix needed
[heap]
pub struct Repository {
pub mut:
	// id             i64
	// node_id        string
	// name           string
	// full_name      string
	license      License
	organization User
	permissions  Permissions
	owner        User
	// description    string      [omitempty]
	// topics         []string
	// default_branch string
	// master_branch  string
	// homepage       string      [omitempty]
	// language       string      [omitempty]
	// size           int
	// // Can be `public`, `private` or `internal`.
	// visibility string
	// private    bool
	// fork       bool
	// archived   bool
	// disabled   bool
	//
	// open_issues_count int
	// forks_count       int
	stargazers_count int
	// subscribers_count int
	// network_count     int
	//
	// has_issues    bool
	// has_projects  bool
	// has_wiki      bool
	// has_pages     bool
	// has_downloads bool
	//
	// allow_rebase_merge     bool
	// allow_squash_merge     bool
	// allow_merge_commit     bool
	// allow_auto_merge       bool
	// delete_branch_on_merge bool
	//
	// is_template bool
	// // template_repository &Repository
	// temp_clone_token string [omitempty]
	//
	// starred_at time.Time
	// pushed_at  time.Time
	// created_at time.Time
	// updated_at time.Time
	//
	// url               string
	// html_url          string
	// archive_url       string
	// assignees_url     string
	// blobs_url         string
	// branches_url      string
	// collaborators_url string
	// comments_url      string
	// commits_url       string
	// compare_url       string
	// contents_url      string
	// contributors_url  string
	// deployments_url   string
	// downloads_url     string
	// events_url        string
	// forks_url         string
	// git_commits_url   string
	// git_refs_url      string
	// git_tags_url      string
	// git_url           string
	// issue_comment_url string
	// issue_events_url  string
	// issues_url        string
	// keys_url          string
	// labels_url        string
	// languages_url     string
	// merges_url        string
	// milestones_url    string
	// notifications_url string
	// pulls_url         string
	// releases_url      string
	// ssh_url           string
	// stargazers_url    string
	// statuses_url      string
	// subscribers_url   string
	// subscriptions_url string
	// tags_url          string
	// teams_url         string
	// trees_url         string
	// clone_url         string
	// mirror_url        string [omitempty]
	// hooks_url         string
	// svn_url           string
}

pub fn (mut r Repository) from_json(obj json2.Any) {
	json_obj := obj.as_map()
	ju.to(mut r, json_obj)

	if field := json_obj['license'] {
		r.license.from_json(field)
	}

	if field := json_obj['organization'] {
		r.organization.from_json(field)
	}

	if field := json_obj['permissions'] {
		r.permissions.from_json(field)
	}

	if field := json_obj['owner'] {
		r.owner.from_json(field)
	}
}
