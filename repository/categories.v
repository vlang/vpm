module repository

import pg
import models

[heap]
pub struct Categories {
	db pg.DB
}

pub fn new_categories(db pg.DB) &Categories {
	return &Categories{
		db: db
	}
}

pub fn (r Categories) create(name string) ?models.Category {
	row := r.db.exec_one("INSERT INTO $categories_table (name) VALUES ('$name') RETURNING $categories_fields;") ?
	return row2category(row)
}

pub fn (r Categories) get_by_id(id int) ?models.Category {
	row := r.db.exec_one('SELECT $categories_fields FROM $categories_table WHERE id = $id;') ?
	return row2category(row)
}

pub fn (r Categories) get_by_name(name string) ?models.Category {
	row := r.db.exec_one("SELECT $categories_fields FROM $categories_table WHERE name = '$name';") ?
	return row2category(row)
}

pub fn (r Categories) get_by_package(id int) ?[]models.Category {
	query := 'SELECT $categories_fields FROM $categories_table ' +
		'INNER JOIN $package_to_category_table ' +
		'ON ${package_to_category_table}.category_id = ${categories_table}.id ' +
		'WHERE ${package_to_category_table}.package_id = $id;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		ctgs << row2category(&row)?
	}
	return ctgs
}

pub fn (r Categories) get_packages(name string) ?[]int {
	query := 'SELECT ${package_to_category_table}.package_id FROM $package_to_category_table ' +
		'INNER JOIN $categories_table ON ${package_to_category_table}.category_id = ${categories_table}.id' +
		"WHERE ${categories_table}.name = '$name' ORDER BY ${categories_table}.packages DESC;"
	rows := r.db.exec(query)?

	return rows.map(fn(row pg.Row)int {
		return row.vals[0].int()
	})
}

pub fn (r Categories) get_popular_categories() ?[]models.Category {
	rows := r.db.exec('SELECT $categories_fields FROM $popular_categories_view;')?

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		ctgs << row2category(&row)?
	}
	return ctgs
}

pub fn (r Categories) get_all() ?[]models.Category {
	rows := r.db.exec('SELECT $categories_fields FROM $categories_table;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut ctgs := []models.Category{cap: rows.len}
	for row in rows {
		ctgs << row2category(&row)?
	}
	return ctgs
}

pub fn (r Categories) add_package(id int, package_id int) ?models.Category {
	row := r.db.exec_one('INSERT INTO $package_to_category_table (category_id, package_id) VALUES ($id, $package_id) RETURNING $categories_fields;') ?
	return row2category(row)
}

pub fn (r Categories) delete(name string) ?models.Category {
	row := r.db.exec_one("DELETE FROM $categories_table WHERE name = '$name' RETURNING $categories_fields;") ?
	return row2category(row)
}
