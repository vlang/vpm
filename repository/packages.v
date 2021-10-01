module repository

import time
import pg
import strings
import models

[heap]
pub struct Packages {
	db pg.DB
}

pub fn new_packages(db pg.DB) &Packages {
	return &Packages{
		db: db
	}
}

pub fn (r Packages) create(package models.Package) ?models.Package {
	query := 'INSERT INTO $packages_table ' +
		'(author_id, name, description, license, repo_url) ' + 'VALUES' + '(' +
		package.author_id.str() + ", '" +
		[package.name, package.description, package.license, package.repo_url].join("', '") +
		"') RETURNING $packages_fields;"
	row := r.db.exec_one(query) ?

	return row2package(row)
}

// fn (r Packages) versions(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT id FROM $versions_table' +
// 		'WHERE package_id = $id ORDER BY date DESC;')
// }

// fn (r Packages) tags(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT ${package_to_tag_table}.tag_id FROM $package_to_tag_table ' +
// 		'INNER JOIN $tags_table ON ${package_to_tag_table}.tag_id = ${tags_table}.id'+
// 		'WHERE ${package_to_tag_table}.package_id = $id ORDER BY ${tags_table}.packages DESC;')
// }

// fn (r Packages) categories(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT ${package_to_category_table}.category_id FROM $package_to_category_table ' +
// 		'INNER JOIN $categories_table ON ${package_to_tag_table}.category_id = ${categories_table}.id'+
// 		'WHERE ${package_to_tag_table}.package_id = $id ORDER BY ${categories_table}.packages DESC;')
// }

pub fn (r Packages) get_by_id(id int) ?models.Package {
	query := 'SELECT $packages_fields FROM $packages_table WHERE id = $id;'
	row := r.db.exec_one(query) ?

	return row2package(row) 
}

pub fn (r Packages) get_by_name(name string) ?models.Package {
	query := "SELECT $packages_fields FROM $packages_table WHERE name = '$name';"
	row := r.db.exec_one(query) ?

	return row2package(row) 
}

pub fn (r Packages) get_by_author(author_id int) ?[]models.Package {
	query := 'SELECT $packages_fields FROM $packages_table WHERE author_id = $author_id ORDER BY updated_at DESC;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) get_by_ids(ids ...int) ?[]models.Package {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT $packages_fields FROM $packages_table WHERE id IN (${query_ids.str()}) ORDER BY updated_at DESC;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) set_description(name string, description string) ?models.Package {
	row := r.db.exec_one("UPDATE $packages_table SET description = '$description' WHERE name = '$name' RETURNING $packages_fields;") ?
	return row2package(row)
}

pub fn (r Packages) set_stars(name string, stars int) ?models.Package {
	row := r.db.exec_one("UPDATE $packages_table SET stars = $stars WHERE name = '$name' RETURNING $packages_fields;") ?
	return row2package(row)
}

pub fn (r Packages) add_download(name string) ?models.Package {
	row := r.db.exec_one("UPDATE $packages_table SET nr_downloads = nr_downloads + 1 WHERE name = '$name' RETURNING $packages_fields;") ?
	return row2package(row)
}

pub fn (r Packages) delete(name string) ?models.Package {
	row := r.db.exec_one("DELETE FROM $packages_table WHERE name = '$name' RETURNING $packages_fields;") ?
	return row2package(row)
}

pub fn (r Packages) get_most_downloadable() ?[]models.Package {
	rows := r.db.exec('SELECT $packages_fields FROM $most_downloadable_view;')?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) get_most_recent_downloads() ?[]models.Package {
	rows := r.db.exec('SELECT $packages_fields FROM $most_recent_downloads_view;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) get_new_packages() ?[]models.Package {
	rows := r.db.exec('SELECT $packages_fields FROM $new_packages_view;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) get_recently_updated() ?[]models.Package {
	rows := r.db.exec('SELECT $packages_fields FROM $recently_updated_view;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << row2package(&row)?
	}
	return pkgs
}

pub fn (r Packages) get_packages_count() ?int {
	return r.db.q_int('SELECT count(*) FROM $packages_table;')
}
