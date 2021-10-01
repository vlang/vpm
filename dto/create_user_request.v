module dto

pub struct CreateUserRequest {
pub:
	github_id  int
	login       string
	name   string
	avatar_url string [json: avatarUrl]
}

