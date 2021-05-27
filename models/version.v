module models

import time

pub struct Version {
pub:
	id         int
	package_id int [json: packageId]

	name         string
	release_url  string [json: releaseUrl] // Github release page
	commit_hash  string [json: commitHash]
	dependencies []int // Version id's of dependency
	nr_downloads int    [json: downloads]

	date time.Time
}
