module entity

import time

@[json: 'user']
pub struct User {
pub mut:
	id         int    @[primary; sql: serial]
	github_id  int
	username   string @[unique]
	avatar_url string

	is_blocked   bool
	block_reason string
	is_admin     bool

	random_id string // TODO remove once more advanced authentication is migrated

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
