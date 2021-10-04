module dto

pub struct User {
pub:
	github_id  int    [json: githubId]
	login      string
	name       string
	avatar_url string [json: avatarUrl]
}
