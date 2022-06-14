module models

import time
import utils

// Version fields for DB query
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
	mut vrs := Version{}
	utils.from_row(mut vrs, row) ?
	return vrs
}
