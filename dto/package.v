module dto

pub struct Package {
pub:
	author_id int

	name        string
	description string
	repository  string
}

pub struct UpdatePackage {
	description string
	keywords    []string
}
