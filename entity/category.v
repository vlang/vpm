module entity

import time

pub struct Category {
pub mut:
	id int
	// For paths `/category/:slug`
	slug string
	// Packages count
	packages int

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
