module models

import time

pub struct Version {
pub:
	id         int
	package_id int

	tag          string // semver tag
	dependencies []int
	downloads    int

	commit_hash  string
	release_url  string // Github release page
	release_date time.Time
}
