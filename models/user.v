module models

pub struct User {
pub:
	id         int
	github_id  int
	name       string // Github name
	username   string // Github username
	avatar_url string [json: avatarUrl] // Github Avatar URL
	is_blocked bool   [skip]
	is_admin   bool   [skip]
}
