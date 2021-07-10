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

	stars         int
	downloads     int
	downloaded_at time.Time [json: downloadedAt]

	created_at time.Time [json: createdAt]
	updated_at time.Time [json: updatedAt]
}

pub fn (package Package) get_old_package() OldPackage {
	return OldPackage{
		id: package.id
		name: package.name
		url: package.repo_url
		nr_downloads: package.downloads
		vcs: package.vcs
	}
}
