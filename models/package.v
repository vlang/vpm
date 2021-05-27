module models

import time

pub struct Package {
pub:
	id        int
	author_id int [json: authorId]

	name        string
	description string
	license     string
	vcs         string
	repo_url    string [json: repoUrl]

	versions     []int
	tags         []int
	categories   []int
	stars        int
	nr_downloads int   [json: downloads]

	created_at time.Time [json: createdAt]
	updated_at time.Time [json: updatedAt]
}

pub fn (package Package) get_old_package() OldPackage {
	return OldPackage{
		id: package.id
		name: package.name
		url: package.repo_url
		nr_downloads: package.nr_downloads
		vcs: package.vcs
	}
}
