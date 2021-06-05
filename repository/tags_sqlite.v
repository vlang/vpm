module repository

import sqlite
import models

pub struct TagsRepo {
	db sqlite.DB
}

pub fn new_tags_repo(db sqlite.DB) TagsRepo {
	return TagsRepo{
		db: db
	}
}

pub fn (r TagsRepo) create(name string) ?int {
	exec(r.db, "INSERT INTO $tags_table (name) VALUES ('$name');") ?
	id := exec_field(r.db, "SELECT id FROM $tags_table WHERE name = '$name';") ?
	return id.int()
}

pub fn (r TagsRepo) get_by_id(id int) ?models.Tag {
	query := 'SELECT name, packages FROM $tags_table WHERE id = $id;'
	row := r.db.exec_one(query) or {
		return error_one(err)
	}

	mut cursor := new_cursor()
	category := models.Tag{
		id: id
		name: row.vals[cursor.next()]
		packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r TagsRepo) get_by_name(name string) ?models.Tag {
	query := "SELECT id, packages FROM $tags_table WHERE name = '$name';"
	row := r.db.exec_one(query) or {
		return error_one(err)
	}

	mut cursor := new_cursor()
	category := models.Tag{
		id: row.vals[cursor.next()].int()
		name: name
		packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r TagsRepo) get_by_package(id int) ?[]models.Tag {
	query := 'SELECT id, name, packages FROM $tags_table '+
		'INNER JOIN $package_to_tag_table '+
		'ON ${package_to_tag_table}.tag_id = ${tags_table}.id '+
		'WHERE ${package_to_tag_table}.package_id = $id;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Tag{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r TagsRepo) get_packages(name string) ?[]int {
	return exec_array(r.db, 'SELECT ${package_to_tag_table}.package_id FROM $package_to_tag_table ' +
		'INNER JOIN $tags_table ON ${package_to_tag_table}.tag_id = ${tags_table}.id' +
		"WHERE ${tags_table}.name = '$name' ORDER BY ${tags_table}.packages DESC;")
}

pub fn (r TagsRepo) get_popular_tags() ?[]models.Tag {
	query := 'SELECT id, name, packages FROM $popular_tags_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Tag{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r TagsRepo) get_all() ?[]models.Tag {
	query := 'SELECT id, name, packages FROM $tags_table;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Tag{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Tag{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r TagsRepo) add_package(id int, package_id int) ? {
	exec(r.db, 'INSERT INTO $package_to_tag_table (tag_id, package_id) VALUES ($id, $package_id);') ?
}

pub fn (r TagsRepo) delete(name string) ? {
	exec(r.db, "DELETE FROM $tags_table WHERE name = '$name';") ?
}
