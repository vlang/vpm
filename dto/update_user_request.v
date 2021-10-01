module dto

pub struct UpdateUserRequest {
pub:
	github_id  int
	login      string
	name       string
	avatar_url string
}
