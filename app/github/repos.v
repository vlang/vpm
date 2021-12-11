module github

import time

pub struct License {
pub:
	key  string
	name string
	url  string

	spdx_id  string
	node_id  string
	html_url string
}

pub struct Permissions {
pub:
	admin    bool
	pull     bool
	triage   bool
	push     bool
	maintain bool
}

[heap]
pub struct Repository {
pub:
	id             i64
	node_id        string
	name           string
	full_name      string
	license        License
	organization   &User
	permissions    Permissions
	owner          &User
	description    string      [omitempty]
	topics         []string
	default_branch string
	master_branch  string
	homepage       string      [omitempty]
	language       string      [omitempty]
	size           int
	// Can be `public`, `private` or `internal`.
	visibility string
	private    bool
	fork       bool
	archived   bool
	disabled   bool

	open_issues_count int
	forks_count       int
	stargazers_count  int
	subscribers_count int
	network_count     int

	has_issues    bool
	has_projects  bool
	has_wiki      bool
	has_pages     bool
	has_downloads bool

	allow_rebase_merge     bool
	allow_squash_merge     bool
	allow_merge_commit     bool
	allow_auto_merge       bool
	delete_branch_on_merge bool

	is_template         bool
	template_repository &Repository
	temp_clone_token    string      [omitempty]

	starred_at time.Time
	pushed_at  time.Time
	created_at time.Time
	updated_at time.Time

	url               string
	html_url          string
	archive_url       string
	assignees_url     string
	blobs_url         string
	branches_url      string
	collaborators_url string
	comments_url      string
	commits_url       string
	compare_url       string
	contents_url      string
	contributors_url  string
	deployments_url   string
	downloads_url     string
	events_url        string
	forks_url         string
	git_commits_url   string
	git_refs_url      string
	git_tags_url      string
	git_url           string
	issue_comment_url string
	issue_events_url  string
	issues_url        string
	keys_url          string
	labels_url        string
	languages_url     string
	merges_url        string
	milestones_url    string
	notifications_url string
	pulls_url         string
	releases_url      string
	ssh_url           string
	stargazers_url    string
	statuses_url      string
	subscribers_url   string
	subscriptions_url string
	tags_url          string
	teams_url         string
	trees_url         string
	clone_url         string
	mirror_url        string [omitempty]
	hooks_url         string
	svn_url           string
}
