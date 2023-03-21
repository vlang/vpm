module main

import time

pub struct User {
pub mut:
	id         int    [primary; sql: serial]
	github_id  int
	username   string
	name       string
	avatar_url string

	is_blocked   bool
	block_reason string
	is_admin     bool

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
