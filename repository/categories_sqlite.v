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
	query := 'SELECT name, packages FROM $categories_table WHERE id = $id;'
	row := r.db.exec_one(query) or {
		return error_one(err)
	}

	mut cursor := new_cursor()
	category := models.Category{
		id: id
		name: row.vals[cursor.next()]
		packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r CategoriesRepo) get_by_name(name string) ?models.Category {
	query := "SELECT id, packages FROM $categories_table WHERE name = '$name';"
	row := r.db.exec_one(query) or {
		return error_one(err)
	}

	mut cursor := new_cursor()
	category := models.Category{
		id: row.vals[cursor.next()].int()
		name: name
		packages: row.vals[cursor.next()].int()
	}

	return category
}

pub fn (r CategoriesRepo) get_by_package(id int) ?[]models.Category {
	query := 'SELECT id, name, packages FROM $categories_table '+
		'INNER JOIN $package_to_category_table '+
		'ON ${package_to_category_table}.category_id = ${categories_table}.id '+
		'WHERE ${package_to_category_table}.package_id = $id;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Category{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r CategoriesRepo) get_packages(name string) ?[]int {
	return exec_array(r.db, 'SELECT ${package_to_category_table}.package_id FROM $package_to_category_table ' +
		'INNER JOIN $categories_table ON ${package_to_category_table}.category_id = ${categories_table}.id' +
		"WHERE ${categories_table}.name = '$name' ORDER BY ${categories_table}.packages DESC;")
}

pub fn (r CategoriesRepo) get_popular_categories() ?[]models.Category {
	query := 'SELECT id, name, packages FROM $popular_categories_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Category{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r CategoriesRepo) get_all() ?[]models.Category {
	query := 'SELECT id, name, packages FROM $categories_table;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		category := models.Category{
			id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			packages: row.vals[cursor.next()].int()
		}
		ctgs << category
	}

	return ctgs
}

pub fn (r CategoriesRepo) add_package(id int, package_id int) ? {
	exec(r.db, 'INSERT INTO $package_to_category_table (category_id, package_id) VALUES ($id, $package_id);') ?
}

pub fn (r CategoriesRepo) delete(name string) ? {
	exec(r.db, "DELETE FROM $categories_table WHERE name = '$name';") ?
}
