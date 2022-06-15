module repository

import pg
import models

pub struct Tags {
	db pg.DB
}

pub fn new_tags(db pg.DB) Tags {
	return Tags{
		db: db
	}
}

pub fn (r Tags) create(slug string, name string) ?models.Tag {
	row := r.db.exec_one("INSERT INTO $models.tags_table (slug, name) VALUES ('$slug', '$name') RETURNING $models.tag_fields;")?
	return models.row2tag(row)
}

pub fn (r Tags) get_by_id(id int) ?models.Tag {
	row := r.db.exec_one('SELECT $models.tag_fields FROM $models.tags_table WHERE id = $id;')?
	return models.row2tag(row)
}

pub fn (r Tags) get_by_slug(slug string) ?models.Tag {
	row := r.db.exec_one("SELECT $models.tag_fields FROM $models.tags_table WHERE slug = '$slug';")?
	return models.row2tag(row)
}

pub fn (r Tags) get_packages(id int) ?[]int {
	query := 'SELECT ${models.package_tags_table}.package_id FROM $models.package_tags_table ' +
		'INNER JOIN $models.tags_table ON ${models.package_tags_table}.tag_id = ${models.tags_table}.id' +
		'WHERE ${models.tags_table}.id = $id ORDER BY ${models.tags_table}.packages DESC;'
	rows := r.db.exec(query)?

	return rows.map(fn (row pg.Row) int {
		return row.vals[0].int()
	})
}

pub fn (r Tags) all() ?[]models.Tag {
	rows := r.db.exec('SELECT $models.tag_fields FROM $models.tags_table;')?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		ctgs << models.row2tag(&row)?
	}
	return ctgs
}

pub fn (r Tags) delete(id int) ?models.Tag {
	row := r.db.exec_one("DELETE FROM $models.tags_table WHERE id = '$id' RETURNING $models.tag_fields;")?
	return models.row2tag(row)
}
