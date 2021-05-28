module repository

import time
import sqlite
import models

pub struct PackagesRepo {
	db sqlite.DB
}

pub fn new_packages_repo(db sqlite.DB) PackagesRepo {
	return PackagesRepo{
		db: db
	}
}

pub fn (r PackagesRepo) create(package models.Package) ?int {
	exec(r.db, 'INSERT INTO $packages_table ' +
		'(author_id, name, description, license, vcs, repo_url) ' + 'VALUES' + '(' +
		package.author_id.str() + ", '" +
		[package.name, package.description, package.license, package.vcs, package.repo_url].join("', '") +
		"');") ?

	id := exec_field(r.db, 'SELECT id FROM $packages_table ' +
		"WHERE repo_url = '$package.repo_url';") ?
	return id.int()
}

fn (r PackagesRepo) versions(id int) ?[]int {
	return exec_array(r.db, 'SELECT id FROM $versions_table' +
		'WHERE package_id = $id ORDER BY date DESC;')
}

fn (r PackagesRepo) tags(id int) ?[]int {
	// TODO: Sort by nr_packages (join or smth)
	return exec_array(r.db, 'SELECT tag_id FROM $package_to_tag_table ' + 'WHERE package_id = $id;')
}

fn (r PackagesRepo) categories(id int) ?[]int {
	// TODO: Sort by nr_packages (join or smth)
	return exec_array(r.db, 'SELECT category_id FROM $package_to_category_table ' +
		'WHERE package_id = $id;')
}

pub fn (r PackagesRepo) get_by_id(id int) ?models.Package {
	query := 'SELECT author_id, name, description, license, ' +
		'vcs, repo_url, stars, nr_downloads, created_at, updated_at ' +
		'FROM $packages_table WHERE id = $id;'
	row := r.db.exec_one(query) or {
		check_one(err) ?
	}

	mut cursor := new_cursor()
	pkg := models.Package{
		id: id
		author_id: row.vals[cursor.next()].int()
		name: row.vals[cursor.next()]
		description: row.vals[cursor.next()]
		license: row.vals[cursor.next()]
		vcs: row.vals[cursor.next()]
		repo_url: row.vals[cursor.next()]
		versions: r.versions(id) ?
		tags: r.tags(id) ?
		categories: r.categories(id) ?
		stars: row.vals[cursor.next()].int()
		nr_downloads: row.vals[cursor.next()].int()
		created_at: time.unix(row.vals[cursor.next()].int())
		updated_at: time.unix(row.vals[cursor.next()].int())
	}

	return pkg
}

pub fn (r PackagesRepo) get_by_name(name string) ?models.Package {
	query := 'SELECT id, author_id, description, license, ' +
		'vcs, repo_url, stars, nr_downloads, created_at, updated_at ' +
		"FROM $packages_table WHERE name = '$name';"
	row := r.db.exec_one(query) or {
		check_one(err) ?
	}

	mut cursor := new_cursor()
	id := row.vals[cursor.next()].int()
	mut pkg := models.Package{
		id: id
		author_id: row.vals[cursor.next()].int()
		name: name
		description: row.vals[cursor.next()]
		license: row.vals[cursor.next()]
		vcs: row.vals[cursor.next()]
		repo_url: row.vals[cursor.next()]
		versions: r.versions(id) ?
		tags: r.tags(id) ?
		categories: r.categories(id) ?
		stars: row.vals[cursor.next()].int()
		nr_downloads: row.vals[cursor.next()].int()
		created_at: time.unix(row.vals[cursor.next()].int())
		updated_at: time.unix(row.vals[cursor.next()].int())
	}

	return pkg
}

pub fn (r PackagesRepo) get_by_author(author_id int) ?[]models.Package {
	query := 'SELECT id, name, description, license, ' +
		'vcs, repo_url, stars, nr_downloads, created_at, updated_at ' +
		'FROM $packages_table WHERE author_id = $author_id ORDER BY updated_at DESC;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		id := row.vals[cursor.next()].int()
		pkg := models.Package{
			id: id
			author_id: author_id
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			versions: r.versions(id) ?
			tags: r.tags(id) ?
			categories: r.categories(id) ?
			stars: row.vals[cursor.next()].int()
			nr_downloads: row.vals[cursor.next()].int()
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) set_description(id int, description string) ? {
	exec(r.db, "UPDATE $packages_table SET description = '$description' WHERE id = $id;") ?
}

pub fn (r PackagesRepo) set_stars(id int, stars int) ? {
	exec(r.db, 'UPDATE $packages_table SET stars = $stars WHERE id = $id;') ?
}

pub fn (r PackagesRepo) add_nr_downloads(id int) ? {
	exec(r.db, 'UPDATE $packages_table SET nr_downloads = nr_downloads + 1 WHERE id = $id;') ?
}

pub fn (r PackagesRepo) delete(id int) ? {
	exec(r.db, 'DELETE FROM $packages_table WHERE id = $id;') ?
}
