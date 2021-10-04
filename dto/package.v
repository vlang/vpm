module dto

pub struct Package {
pub:
	author_id   int    [json: authorId]
	name        string
	description string
	license     string
	repo_url    string [json: repoUrl]
}
