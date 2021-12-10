module dto

pub struct NewPackage {
pub:
	author_id int
	gh_repo_id int

	name        string
	description string
	repository  string
}

pub struct UpdatePackage {
pub:
	description string
	keywords    []string
}
