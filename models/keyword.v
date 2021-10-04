module models

import utils

// Keyword fields for Postgres SELECT and RETURNING
pub const keyword_fields = 'id, slug, name, packages'

pub struct Keyword {
pub:
	id       int
	slug     string
	name     string
	packages int
}

// Converts database row into Keyword.
// Row values must match with `keyword_fields` otherwise it will panic
pub fn row2keyword(row utils.Row) ?Keyword {
	mut i := utils.row_iterator(row)

	return Keyword{
		id: i.next() ?.int()
		slug: i.next() ?
		name: i.next() ?
		packages: i.next() ?.int()
	}
}
