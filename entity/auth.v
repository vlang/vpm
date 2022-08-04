module entity

import time

pub struct Auth {
pub mut:
	username string
	// Currently only one kind - `github_oauth`
	kind  string = 'github_oauth'
	value string

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
