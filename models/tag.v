module models

import utils

// Tags fields for Postgres SELECT and RETURNING
pub const (
	tags_table = 'tags'
	tag_fields = 'id, slug, packages'
)

pub struct Tag {
pub:
	id       int
	slug     string
	packages int
}

// Converts database row into Tag.
// Row values must match with `tags_fields` otherwise it will panic
pub fn row2tag(row utils.Row) ?Tag {
	mut i := utils.row_iterator(row)

	return Tag{
		id: i.next() ?.int()
		slug: i.next() ?
		packages: i.next() ?.int()
	}
}
