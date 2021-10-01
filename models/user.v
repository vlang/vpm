module models

pub struct User {
pub:
	id         int
	github_id  int    // Github ID
	login      string // Github Login
	name       string // Github Name
	avatar_url string
	is_blocked bool
	is_admin   bool
}
