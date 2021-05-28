module repository

import sqlite
import models

pub struct CategoriesRepo {
	db sqlite.DB
}

pub fn new_categories_repo(db sqlite.DB) CategoriesRepo {
	return CategoriesRepo{
		db: db
	}
}

pub fn (r CategoriesRepo) create(name string) ?int {
	exec(r.db, "INSERT INTO $categories_table (name) VALUES ('$name');") ?
	id := exec_field(r.db, "SELECT id FROM $categories_table WHERE name = '$name';") ?
	return id.int()
}

pub fn (r CategoriesRepo) get_by_id(id int) ?models.Category {
	query := 'SELECT name, nr_packages FROM $categories_table WHERE id = $id;'
	row := r.db.exec_one(query) or {
		check_one(err) ?
	}

	mut cursor := new_cursor()
	category := models.Category{
		id: id
		name: row.vals[cursor.next()]
		nr_packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r CategoriesRepo) get_by_name(name string) ?models.Category {
	query := "SELECT id, nr_packages FROM $categories_table WHERE name = '$name';"
	row := r.db.exec_one(query) or {
		check_one(err) ?
	}

	mut cursor := new_cursor()
	category := models.Category{
		id: row.vals[cursor.next()].int()
		name: name
		nr_packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r CategoriesRepo) get_packages(id int) ?[]int {
	// TODO: Sort by nr_packages (join or smth)
	return exec_array(r.db, 'SELECT package_id FROM $package_to_category_table ' +
		'WHERE category_id = $id ORDER BY package_id DESC;')
}

pub fn (r CategoriesRepo) add_package(id int, package_id int) ? {
	exec(r.db, 'INSERT INTO $package_to_category_table (category_id, package_id) VALUES ($id, $package_id);') ?
}

pub fn (r CategoriesRepo) delete(id int) ? {
	exec(r.db, 'DELETE FROM $categories_table WHERE id = $id;') ?
}
