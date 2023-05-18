module main

import time

pub struct Category {
pub mut:
	id int
	// For paths `/search?category=slug`
	slug string
	// Packages count
	packages int

	name       string
	nr_modules int

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
