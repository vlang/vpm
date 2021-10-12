module models

import time
import utils

// Version fields for Postgres SELECT and RETURNING
pub const (
	versions_table = 'versions'
	version_fields = 'id, package_id, tag, downloads, commit_hash, release_url, release_date'
)

pub struct Version {
pub:
	id         int
	package_id int

	tag       string // semver tag
	downloads int

	commit_hash  string
	release_url  string // Github release page
	release_date time.Time
}

// Converts database row into Version.
// Row values must match with `version_fields` otherwise it will panic
pub fn row2version(row utils.Row) ?Version {
	mut i := utils.row_iterator(row)

	return Version{
		id: i.next() ?.int()
		package_id: i.next() ?.int()
		tag: i.next() ?
		downloads: i.next() ?.int()
		commit_hash: i.next() ?
		release_url: i.next() ?
		release_date: time.parse(i.next() ?) ?
	}
}
