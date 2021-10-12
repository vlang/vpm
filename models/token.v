module models

import time
import utils

// ApiToken fields for Postgres SELECT and RETURNING
pub const (
	tokens_table = 'tokens'
	token_fields = 'id, user_id, name, token, revoked, created_at, last_used_at'
)

pub struct ApiToken {
pub:
	id      int
	user_id int
	name    string

	token   string
	revoked bool

	created_at   time.Time
	last_used_at time.Time
}

// Converts database row into Token.
// Row values must match with `token_fields` otherwise it will panic
pub fn row2token(row utils.Row) ?ApiToken {
	mut i := utils.row_iterator(row)

	return ApiToken{
		id: i.next() ?.int()
		user_id: i.next() ?.int()
		name: i.next() ?
		token: i.next() ?
		revoked: i.next() ?.bool()
		created_at: time.parse(i.next() ?) ?
		last_used_at: time.parse(i.next() ?) ?
	}
}
