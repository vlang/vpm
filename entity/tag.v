module entity

import time

pub struct Tag {
pub mut:
	id         int
	package_id int

	name string

	downloads     int
	downloaded_at time.Time = time.now()

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
