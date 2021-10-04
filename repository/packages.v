module repository

import pg
import strings
import dto
import models

pub struct Packages {
	db pg.DB
}

pub fn new_packages(db pg.DB) Packages {
	return Packages{
		db: db
	}
}

pub fn (r Packages) create(package dto.Package) ?models.Package {
	query := 'INSERT INTO $packages_table ' + '(author_id, name, description, license, repo_url) ' +
		'VALUES' + '(' + package.author_id.str() + ", '" +
		[package.name, package.description, package.license, package.repo_url].join("', '") +
		"') RETURNING $packages_fields;"
	row := r.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (r Packages) get_by_id(id int) ?models.Package {
	query := 'SELECT $packages_fields FROM $packages_table WHERE id = $id;'
	row := r.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (r Packages) get_by_name(name string) ?models.Package {
	query := "SELECT $packages_fields FROM $packages_table WHERE name = '$name';"
	row := r.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (r Packages) get_by_author(author_id int) ?[]models.Package {
	query := 'SELECT $packages_fields FROM $packages_table WHERE author_id = $author_id ORDER BY updated_at DESC;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (r Packages) get_by_ids(ids ...int) ?[]models.Package {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT $packages_fields FROM $packages_table WHERE id IN ($query_ids.str());'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (r Packages) set_description(id int, description string) ?models.Package {
	row := r.db.exec_one("UPDATE $packages_table SET description = '$description' WHERE id = $id RETURNING $packages_fields;") ?
	return models.row2package(row)
}

pub fn (r Packages) set_stars(id int, stars int) ?models.Package {
	row := r.db.exec_one('UPDATE $packages_table SET stars = $stars WHERE id = $id RETURNING $packages_fields;') ?
	return models.row2package(row)
}

pub fn (r Packages) add_download(id int) ?models.Package {
	row := r.db.exec_one('UPDATE $packages_table SET nr_downloads = nr_downloads + 1 WHERE id = $id RETURNING $packages_fields;') ?
	return models.row2package(row)
}

pub fn (r Packages) delete(id int) ?models.Package {
	row := r.db.exec_one('DELETE FROM $packages_table WHERE id = $id RETURNING $packages_fields;') ?
	return models.row2package(row)
}

pub fn (r Packages) get_most_downloadable() ?[]models.Package {
	rows := r.db.exec('SELECT $packages_fields FROM $most_downloadable_view;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (r Packages) get_packages_count() ?int {
	return r.db.q_int('SELECT count(*) FROM $packages_table;')
}

pub fn (r Packages) versions(id int) ?[]int {
	rows := r.db.exec('SELECT id FROM $versions_table WHERE package_id = $id ORDER BY release_date DESC;') ?

	return rows.map(fn (row pg.Row) int {
		return row.vals[0].int()
	})
}
