module dto

pub struct NewPackage {
pub:
	repository string
}

pub struct UpdatePackage {
	description string
	keywords    []string
}
