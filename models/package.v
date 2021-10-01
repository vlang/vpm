module models

import time

pub struct Package {
pub:
	id        int
	author_id int

	name        string
	description string
	license     string
	repo_url    string

	stars         int
	downloads     int
	downloaded_at time.Time

	created_at time.Time
	updated_at time.Time
}

pub fn (package Package) get_old_package() OldPackage {
	return OldPackage{
		id: package.id
		name: package.name
		url: package.repo_url
		nr_downloads: package.downloads
	}
}
