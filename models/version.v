module models

import time
import utils

// Version fields for Postgres SELECT and RETURNING
pub const (
	versions_table = 'versions'
	version_fields = 'id, package_id, semver, downloads, download_url, release_date'
)

pub struct Version {
pub:
	id         int
	package_id int

	semver       string
	downloads    int
	download_url string
	release_date time.Time
}

// Converts database row into Version.
// Row values must match with `version_fields` otherwise it will panic
pub fn row2version(row utils.Row) ?Version {
	mut i := utils.row_iterator(row)

	return Version{
		id: i.next() ?.int()
		package_id: i.next() ?.int()
		semver: i.next() ?
		downloads: i.next() ?.int()
		download_url: i.next() ?
		release_date: time.parse(i.next() ?) ?
	}
}
