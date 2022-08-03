module repo

import pg
import vpm.entity
import vpm.lib.sql

const (
	tags_table = 'tags'
)

pub struct TagRepo {
	db pg.DB
}

pub fn new_tag_repo(db pg.DB) TagRepo {
	return TagRepo{
		db: db
	}
}

pub fn (repo TagRepo) create(tag entity.Tag) ?entity.Tag {
	all := sql.to_idents<entity.Tag>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(tag, idents)

	query := 'insert into $tags_table (${idents.join(', ')}) ' +
		'values (${values.join(', ')}) '+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Tag>(row.vals, all)
}

pub fn (repo TagRepo) get_by_package_id(package_id int) ?[]entity.Tag {
	all := sql.to_idents<entity.Tag>()

	query := 'select ${all.join(', ')} from $tags_table ' +
		'where package_id = $package_id;'

	rows := repo.db.exec(query)?
	mut tags := []entity.Tag{cap: rows.len}
	for _, row in rows {
		tags << sql.from_row_to<entity.Tag>(row.vals, all)?
	}
	return tags
}

pub fn (repo TagRepo) update(tag entity.Tag) ?entity.Tag {
	all := sql.to_idents<entity.Tag>()
	idents := all.filter(it !in ['id', 'created_at', 'updated_at'])
	values := sql.to_values(tag, idents)
	set := sql.to_set(idents, values)

	query := 'update $tags_table ' +
		'set ${set.join(', ')} '+
		'where id = $tag.id '+
		'returning ${all.join(', ')};'

	row := repo.db.exec_one(query)?
	return sql.from_row_to<entity.Tag>(row.vals, all)
}
