module models

import utils

// User fields for Postgres SELECT and RETURNING
pub const (
	users_table = 'users'
	user_fields = 'id, gh_id, gh_login, gh_avatar, name, access_token, is_blocked, block_reason, is_admin'
)

pub struct User {
pub:
	id        int
	gh_id     int
	gh_login  string
	gh_avatar string
	name      string

	access_token string

	is_blocked   bool
	block_reason string
	is_admin     bool
}

// Converts database row into User.
// Row values must match with `user_fields` otherwise it will panic
pub fn row2user(row utils.Row) ?User {
	mut i := utils.row_iterator(row)

	return User{
		id: i.next() ?.int()
		gh_id: i.next() ?.int()
		gh_login: i.next() ?
		gh_avatar: i.next() ?
		name: i.next() ?
		access_token: i.next() ?
		is_blocked: i.next() ?.bool()
		block_reason: i.next() ?
		is_admin: i.next() ?.bool()
	}
}
