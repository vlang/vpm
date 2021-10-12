module models

import time
import utils

// Package fields for Postgres SELECT and RETURNING
pub const (
	packages_table = 'packages'
	package_fields = 'id, author_id, name, description, documentation, repository, stars, downloads, downloaded_at, created_at, updated_at'
)

pub struct Package {
pub:
	id        int
	author_id int

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

pub fn (package Package) get_old_package() OldPackage {
	return OldPackage{
		id: package.id
		name: package.name
		url: package.repository
		nr_downloads: package.downloads
	}
}

// Converts database row into Package.
// Row values must match with `package_fields` otherwise it will panic
pub fn row2package(row utils.Row) ?Package {
	mut i := utils.row_iterator(row)

	return Package{
		id: i.next() ?.int()
		author_id: i.next() ?.int()
		name: i.next() ?
		description: i.next() ?
		documentation: i.next() ?
		repository: i.next() ?
		stars: i.next() ?.int()
		downloads: i.next() ?.int()
		downloaded_at: time.unix(i.next() ?.i64())
		created_at: time.parse(i.next() ?) ?
		updated_at: time.parse(i.next() ?) ?
	}
}
