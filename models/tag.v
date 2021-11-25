module models

import utils

// Tags fields for Postgres SELECT and RETURNING
pub const (
	tags_table = 'tags'
	tag_fields = 'id, slug, name, packages'
)

pub struct Tags {
pub:
	id       int
	slug     string
	name     string
	packages ints
}

// Converts database row into Tag.
// Row values must match with `tags_fields` otherwise it will panic
pub fn row2tag(row utils.Row) ?Tag {
	mut i := utils.row_iterator(row)

	return Tag{
		id: i.next() ?.int()
		slug: i.next() ?
		name: i.next() ?
		packages: i.next() ?.int()
	}
}
