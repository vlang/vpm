module entity

import time

pub struct Auth {
pub mut:
	user_id int
	// Currently only one kind - `github_oauth`
	kind  string = 'github_oauth'
	value string

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
