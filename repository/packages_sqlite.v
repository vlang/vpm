module repository

import time
import sqlite
import strings
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

	id := exec_field(r.db, "SELECT id FROM $packages_table WHERE name = '$package.name';") ?
	return id.int()
}

// fn (r PackagesRepo) versions(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT id FROM $versions_table' +
// 		'WHERE package_id = $id ORDER BY date DESC;')
// }

// fn (r PackagesRepo) tags(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT ${package_to_tag_table}.tag_id FROM $package_to_tag_table ' +
// 		'INNER JOIN $tags_table ON ${package_to_tag_table}.tag_id = ${tags_table}.id'+
// 		'WHERE ${package_to_tag_table}.package_id = $id ORDER BY ${tags_table}.packages DESC;')
// }

// fn (r PackagesRepo) categories(id int) ?[]int {
// 	return exec_array(r.db, 'SELECT ${package_to_category_table}.category_id FROM $package_to_category_table ' +
// 		'INNER JOIN $categories_table ON ${package_to_tag_table}.category_id = ${categories_table}.id'+
// 		'WHERE ${package_to_tag_table}.package_id = $id ORDER BY ${categories_table}.packages DESC;')
// }

pub fn (r PackagesRepo) get_by_id(id int) ?models.Package {
	query := 'SELECT author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $packages_table WHERE id = $id;'
	row := r.db.exec_one(query) or { return error_one(err) }

	mut cursor := new_cursor()
	pkg := models.Package{
		id: id
		author_id: row.vals[cursor.next()].int()
		name: row.vals[cursor.next()]
		description: row.vals[cursor.next()]
		license: row.vals[cursor.next()]
		vcs: row.vals[cursor.next()]
		repo_url: row.vals[cursor.next()]
		stars: row.vals[cursor.next()].int()
		downloads: row.vals[cursor.next()].int()
		downloaded_at: time.unix(row.vals[cursor.next()].int())
		created_at: time.unix(row.vals[cursor.next()].int())
		updated_at: time.unix(row.vals[cursor.next()].int())
	}

	return pkg
}

pub fn (r PackagesRepo) get_by_name(name string) ?models.Package {
	query := 'SELECT id, author_id, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		"FROM $packages_table WHERE name = '$name';"
	row := r.db.exec_one(query) or { return error_one(err) }

	mut cursor := new_cursor()
	mut pkg := models.Package{
		id: row.vals[cursor.next()].int()
		author_id: row.vals[cursor.next()].int()
		name: name
		description: row.vals[cursor.next()]
		license: row.vals[cursor.next()]
		vcs: row.vals[cursor.next()]
		repo_url: row.vals[cursor.next()]
		stars: row.vals[cursor.next()].int()
		downloads: row.vals[cursor.next()].int()
		downloaded_at: time.unix(row.vals[cursor.next()].int())
		created_at: time.unix(row.vals[cursor.next()].int())
		updated_at: time.unix(row.vals[cursor.next()].int())
	}

	return pkg
}

pub fn (r PackagesRepo) get_by_author(author_id int) ?[]models.Package {
	query := 'SELECT id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $packages_table WHERE author_id = $author_id ORDER BY updated_at DESC;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: author_id
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) get_by_ids(ids ...int) ?[]models.Package {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT id, author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $packages_table WHERE id IN ($query_ids.str()) ORDER BY updated_at DESC;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) set_description(name string, description string) ? {
	exec(r.db, "UPDATE $packages_table SET description = '$description' WHERE name = '$name';") ?
}

pub fn (r PackagesRepo) set_stars(name string, stars int) ? {
	exec(r.db, "UPDATE $packages_table SET stars = $stars WHERE name = '$name';") ?
}

pub fn (r PackagesRepo) add_download(name string) ? {
	exec(r.db, "UPDATE $packages_table SET nr_downloads = nr_downloads + 1 WHERE name = '$name';") ?
}

pub fn (r PackagesRepo) delete(name string) ? {
	exec(r.db, "DELETE FROM $packages_table WHERE name = '$name';") ?
}

pub fn (r PackagesRepo) get_most_downloadable() ?[]models.Package {
	query := 'SELECT id, author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $most_downloadable_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) get_most_recent_downloads() ?[]models.Package {
	query := 'SELECT id, author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $most_recent_downloads_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) get_new_packages() ?[]models.Package {
	query := 'SELECT id, author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $new_packages_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) get_recently_updated() ?[]models.Package {
	query := 'SELECT id, author_id, name, description, license, ' +
		'vcs, repo_url, stars, downloads, downloaded_at, created_at, updated_at ' +
		'FROM $recently_updated_view;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Package{cap: rows.len}
	for row in rows {
		mut cursor := new_cursor()
		pkg := models.Package{
			id: row.vals[cursor.next()].int()
			author_id: row.vals[cursor.next()].int()
			name: row.vals[cursor.next()]
			description: row.vals[cursor.next()]
			license: row.vals[cursor.next()]
			vcs: row.vals[cursor.next()]
			repo_url: row.vals[cursor.next()]
			stars: row.vals[cursor.next()].int()
			downloads: row.vals[cursor.next()].int()
			downloaded_at: time.unix(row.vals[cursor.next()].int())
			created_at: time.unix(row.vals[cursor.next()].int())
			updated_at: time.unix(row.vals[cursor.next()].int())
		}
		pkgs << pkg
	}

	return pkgs
}

pub fn (r PackagesRepo) get_packages_count() ?int {
	query := 'SELECT count(*) FROM $packages_table;'
	count := exec_field(r.db, query) ?
	return count.int()
}
