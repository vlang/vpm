module models

import time

pub struct Version {
pub:
	id         int
	package_id int [json: packageId]

	name         string // Name of tag
	commit_hash  string [json: commitHash]
	release_url  string [json: releaseUrl] // Github release page
	dependencies []int // Version id's of dependency
	downloads    int

	date time.Time
}
