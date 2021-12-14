module github

import time
import x.json2
import utils

[heap]
pub struct User {
pub:
	name        string [omitempty]
	email       string [omitempty]
	login       string
	id          i64
	node_id     string
	avatar_url  string
	gravatar_id string
	// Can be `User` or `Organization`.
	user_type  string    [json: 'type']
	site_admin bool
	starred_at time.Time

	url                 string
	html_url            string
	followers_url       string
	following_url       string
	gists_url           string
	starred_url         string
	subscriptions_url   string
	organizations_url   string
	repos_url           string
	events_url          string
	received_events_url string
}

pub fn (mut u User) from_json(obj json2.Any) {
	utils.from_json(mut u, obj.as_map())
}
