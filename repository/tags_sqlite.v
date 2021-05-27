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
	query := 'SELECT name, nr_packages FROM $tags_table WHERE id = $id;'
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	category := models.Tag{
		id: id
		name: row.vals[cursor.next()]
		nr_packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r TagsRepo) get_by_name(name string) ?models.Tag {
	query := "SELECT id, nr_packages FROM $tags_table WHERE name = '$name';"
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	category := models.Tag{
		id: row.vals[cursor.next()].int()
		name: name
		nr_packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r TagsRepo) get_packages(id int) ?[]int {
	// TODO: Sort by nr_packages (join or smth)
	return exec_array(r.db, 'SELECT package_id FROM $package_to_tag_table ' +
		'WHERE tag_id = $id ORDER BY package_id DESC;')
}

pub fn (r TagsRepo) add_package(id int, package_id int) ? {
	exec(r.db, 'INSERT INTO $package_to_tag_table (tag_id, package_id) VALUES ($id, $package_id);') ?
}

pub fn (r TagsRepo) delete(id int) ? {
	return exec(r.db, 'DELETE FROM $tags_table WHERE id = $id;')
}
