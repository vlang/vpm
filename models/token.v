module models

import time
import utils

// ApiToken fields for DB query
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
	mut tkn := ApiToken{}
	utils.from_row(mut tkn, row)?
	return tkn
}
