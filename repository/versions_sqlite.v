module repository

import time
import sqlite
import models

pub struct VersionsRepo {
	db sqlite.DB
}

pub fn new_versions_repo(db sqlite.DB) VersionsRepo {
	return VersionsRepo{
		db: db
	}
}

fn (r VersionsRepo) dependencies(id int) ?[]int {
	// TODO: Sort by nr_downloads (join or smth)
	return exec_array(r.db, 'SELECT dependency_id FROM $dependencies_table' +
		'WHERE version_id = $id;')
}

pub fn (r VersionsRepo) create(version models.Version) ?int {
	exec(r.db, 'INSERT INTO $versions_table ' +
		'(package_id, date, name, release_url, commit_hash) ' + 'VALUES' + '(' +
		version.package_id.str() + ',' + version.date.unix_time().str() + ", '" +
		[version.name, version.release_url, version.commit_hash].join("', '") + "');") ?

	id := exec_field(r.db, 'SELECT id FROM $versions_table ' +
		"WHERE package_id = $version.package_id AND commit_hash = '$version.commit_hash';") ?
	return id.int()
}

pub fn (r VersionsRepo) get_by_id(id int) ?models.Version {
	query := 'SELECT package_id, name, release_url, commit_hash, nr_downloads, date' +
		'FROM $versions_table WHERE id = $id;'
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	version := models.Version{
		id: id
		package_id: row.vals[cursor.next()].int()
		name: row.vals[cursor.next()]
		release_url: row.vals[cursor.next()]
		commit_hash: row.vals[cursor.next()]
		dependencies: r.dependencies(id) ?
		nr_downloads: row.vals[cursor.next()].int()
		date: time.unix(row.vals[cursor.next()].int())
	}

	return version
}

pub fn (r VersionsRepo) get_by_name(name string) ?models.Version {
	query := 'SELECT id, package_id, release_url, commit_hash, nr_downloads, date' +
		'FROM $versions_table WHERE name = $name;'
	row := r.db.exec_one(query) ?

	mut cursor := new_cursor()
	id := row.vals[cursor.next()].int()
	version := models.Version{
		id: id
		package_id: row.vals[cursor.next()].int()
		name: name
		release_url: row.vals[cursor.next()]
		commit_hash: row.vals[cursor.next()]
		dependencies: r.dependencies(id) ?
		nr_downloads: row.vals[cursor.next()].int()
		date: time.unix(row.vals[cursor.next()].int())
	}

	return version
}

pub fn (r VersionsRepo) get_by_package(package_id int) ?[]models.Version {
	query := 'SELECT id, name, release_url, commit_hash, nr_downloads, date' +
		'FROM $versions_table WHERE package_id = $package_id ORDER BY date DESC;'
	rows, code := r.db.exec(query)
	check_sql_code(code) ?

	mut versions := []models.Version{}
	for row in rows {
		mut cursor := new_cursor()
		id := row.vals[cursor.next()].int()
		version := models.Version{
			id: id
			package_id: package_id
			name: row.vals[cursor.next()]
			release_url: row.vals[cursor.next()]
			commit_hash: row.vals[cursor.next()]
			dependencies: r.dependencies(id) ?
			nr_downloads: row.vals[cursor.next()].int()
			date: time.unix(row.vals[cursor.next()].int())
		}
		versions << version
	}

	return versions
}

pub fn (r VersionsRepo) add_nr_downloads(id int) ? {
	exec(r.db, 'UPDATE $versions_table SET nr_downloads = nr_downloads + 1 WHERE id = $id;') ?
}

pub fn (r VersionsRepo) delete(id int) ? {
	exec(r.db, 'DELETE FROM $versions_table WHERE id = $id;') ?
}
