module entity

import time

@[json: 'user']
pub struct User {
pub mut:
	id         int @[primary; sql: serial]
	github_id  int
	username   string @[unique]
	avatar_url string

	is_blocked   bool
	block_reason string
	is_admin     bool

	// Session credential used for cookie authentication. It must never be
	// included in serialized User values.
	random_id string @[json: '-']

	// GitHub OAuth token used for repository permission checks during package operations.
	// It must never be included in serialized User values.
	github_token string @[json: '-']

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}
