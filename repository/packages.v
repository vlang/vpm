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

pub fn (repo Packages) create(package dto.NewPackage) ?models.Package {
	query := 'INSERT INTO $models.packages_table (author_id, name, description, repository) ' +
		'VALUES' + '(' + package.author_id.str() + ", '" +
		[package.name, package.description, package.repository].join("', '") +
		"') RETURNING $models.package_fields;"
	row := repo.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (repo Packages) get_by_id(id int) ?models.Package {
	query := 'SELECT $models.package_fields FROM $models.packages_table WHERE id = $id;'
	row := repo.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (repo Packages) get_by_name(name string) ?models.Package {
	query := "SELECT $models.package_fields FROM $models.packages_table WHERE name = '$name';"
	row := repo.db.exec_one(query) ?
	return models.row2package(row)
}

pub fn (repo Packages) get_by_author(author_id int) ?[]models.Package {
	query := 'SELECT $models.package_fields FROM $models.packages_table WHERE author_id = $author_id ORDER BY updated_at DESC;'
	rows := repo.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (repo Packages) get_by_ids(ids ...int) ?[]models.Package {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT $models.package_fields FROM $models.packages_table WHERE id IN ($query_ids.str());'
	rows := repo.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (repo Packages) set_description(id int, description string) ?models.Package {
	row := repo.db.exec_one("UPDATE $models.packages_table SET description = '$description' WHERE id = $id RETURNING $models.package_fields;") ?
	return models.row2package(row)
}

pub fn (repo Packages) set_stars(id int, stars int) ?models.Package {
	row := repo.db.exec_one('UPDATE $models.packages_table SET stars = $stars WHERE id = $id RETURNING $models.package_fields;') ?
	return models.row2package(row)
}

pub fn (repo Packages) delete(id int) ?models.Package {
	row := repo.db.exec_one('DELETE FROM $models.packages_table WHERE id = $id RETURNING $models.package_fields;') ?
	return models.row2package(row)
}

pub fn (repo Packages) get_most_downloadable() ?[]models.Package {
	rows := repo.db.exec('SELECT $models.package_fields FROM $most_downloadable_view;') ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		pkgs << models.row2package(&row) ?
	}
	return pkgs
}

pub fn (repo Packages) get_packages_count() ?int {
	return repo.db.q_int('SELECT count(*) FROM $models.packages_table;')
}
