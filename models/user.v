module models

pub struct User {
pub:
	id         int
	name       string
	username   string
	avatar_url string [json: avatarUrl]
	is_blocked bool   [skip]
	is_admin   bool   [skip]
pub mut:
	login_attempts int [skip]
}
