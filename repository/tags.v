module repository

import pg
import models

[heap]
pub struct Tags {
	db pg.DB
}

pub fn new_tags(db pg.DB) &Tags {
	return &Tags{
		db: db
	}
}

pub fn (r Tags) create(name string) ?models.Tag {
	row := r.db.exec_one("INSERT INTO $tags_table (name) VALUES ('$name') RETURNING $tags_fields;") ?
	return row2tag(row)
}

pub fn (r Tags) get_by_id(id int) ?models.Tag {
	row := r.db.exec_one('SELECT $tags_fields FROM $tags_table WHERE id = $id;') ?
	return row2tag(row)
}

pub fn (r Tags) get_by_name(name string) ?models.Tag {
	row := r.db.exec_one("SELECT $tags_fields FROM $tags_table WHERE name = '$name';") ?
	return row2tag(row)
}

pub fn (r Tags) get_by_package(id int) ?[]models.Tag {
	query := 'SELECT $tags_fields FROM $tags_table ' +
		'INNER JOIN $package_to_tag_table ' +
		'ON ${package_to_tag_table}.tag_id = ${tags_table}.id ' +
		'WHERE ${package_to_tag_table}.package_id = $id;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		ctgs << row2tag(&row)?
	}
	return ctgs
}

pub fn (r Tags) get_packages(name string) ?[]int {
	query := 'SELECT ${package_to_tag_table}.package_id FROM $package_to_tag_table ' +
		'INNER JOIN $tags_table ON ${package_to_tag_table}.tag_id = ${tags_table}.id' +
		"WHERE ${tags_table}.name = '$name' ORDER BY ${tags_table}.packages DESC;"
	rows := r.db.exec(query)?

	return rows.map(fn(row pg.Row)int {
		return row.vals[0].int()
	})
}

pub fn (r Tags) get_popular_categories() ?[]models.Tag {
	rows := r.db.exec('SELECT $tags_fields FROM $popular_tags_view;')?

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		ctgs << row2tag(&row)?
	}
	return ctgs
}

pub fn (r Tags) get_all() ?[]models.Tag {
	rows := r.db.exec('SELECT $tags_fields FROM $tags_table;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		ctgs << row2tag(&row)?
	}
	return ctgs
}

pub fn (r Tags) add_package(id int, package_id int) ?models.Tag {
	row := r.db.exec_one('INSERT INTO $package_to_tag_table (tag_id, package_id) VALUES ($id, $package_id) RETURNING $tags_fields;') ?
	return row2tag(row)
}

pub fn (r Tags) delete(name string) ?models.Tag {
	row := r.db.exec_one("DELETE FROM $tags_table WHERE name = '$name' RETURNING $tags_fields;") ?
	return row2tag(row)
}
