module main

import time

pub struct User {
pub mut:
	id        int    [primary; sql: serial]
	github_id int
	username  string [unique]
	// name       string
	avatar_url string

	is_blocked   bool
	block_reason string
	is_admin     bool

	random_id string // TODO remove once more advanced authentication is migrated

	created_at time.Time = time.now()
	updated_at time.Time = time.now()
}

fn (app &App) retrieve_user(id int, random_id string) ?User {
	users := sql app.db {
		select from User where id == id && random_id == random_id
	} or { return none }
	if users.len == 0 {
		return none
	}
	return users[0]
}
