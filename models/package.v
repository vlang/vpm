module models

import time
import utils

// Package fields for DB query
pub const (
	packages_table = 'packages'
	package_fields = 'id, author_id, gh_repo_id, name, description, documentation, repository, stars, downloads, downloaded_at, created_at, updated_at'
)

pub const (
	package_tags_table = 'package_tags'
)

pub struct Package {
pub:
	id         int
	author_id  int
	gh_repo_id int

	name          string
	description   string
	documentation string
	repository    string

	stars         int
	downloads     int
	downloaded_at time.Time

	created_at time.Time
	updated_at time.Time
}

// Backward compatibility for V <=0.2.4
pub struct OldPackage {
pub:
	id           int
	name         string
	vcs          string = 'git'
	url          string
	nr_downloads int
}

pub fn (package Package) get_old_package(login string) OldPackage {
	return OldPackage{
		id: package.id
		name: login + '.' + package.name
		url: package.repository
		nr_downloads: package.downloads
	}
}

// Converts database row into Package.
// Row values must match with `package_fields` otherwise it will panic
pub fn row2package(row utils.Row) ?Package {
	mut pkg := Package{}
	utils.from_row(mut pkg, row)?
	return pkg
}
