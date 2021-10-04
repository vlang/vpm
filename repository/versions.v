module repository

import pg
import models
import strings

pub struct Versions {
	db pg.DB
}

pub fn new_versions(db pg.DB) Versions {
	return Versions{
		db: db
	}
}

fn (r Versions) dependencies(id int) ?[]int {
	// TODO: Sort by downloads (join with versions table or smth)
	rows := r.db.exec('SELECT dependency_id FROM $dependencies_table WHERE version_id = $id;') ?
	return rows.map(fn (row pg.Row) int {
		return row.vals[0].int()
	})
}

pub fn (r Versions) create(version models.Version) ?models.Version {
	row := r.db.exec_one('INSERT INTO $versions_table ' +
		'(package_id, release_date, tag, release_url, commit_hash) ' + 'VALUES' + '(' +
		version.package_id.str() + ',' + version.release_date.unix_time().str() + ", '" +
		[version.tag, version.release_url, version.commit_hash].join("', '") +
		"') RETURNING $versions_fields;") ?
	return models.row2version(row)
}

pub fn (r Versions) get_by_id(id int) ?models.Version {
	query := 'SELECT $versions_fields FROM $versions_table WHERE id = $id;'
	row := r.db.exec_one(query) ?
	return models.row2version(row)
}

pub fn (r Versions) get(package_id int, name string) ?models.Version {
	query := "SELECT $versions_fields FROM $versions_table WHERE package_id = $package_id AND name = '$name';"
	row := r.db.exec_one(query) ?
	return models.row2version(row)
}

pub fn (r Versions) get_by_package(package_id int) ?[]models.Version {
	query := 'SELECT $versions_fields FROM $versions_table WHERE package_id = $package_id ORDER BY date DESC;'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut versions := []models.Version{}
	for row in rows {
		versions << models.row2version(&row) ?
	}

	return versions
}

pub fn (r Versions) get_by_ids(ids ...int) ?[]models.Version {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT $versions_fields FROM $versions_table WHERE id IN ($query_ids.str());'
	rows := r.db.exec(query) ?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Version{cap: rows.len}
	for row in rows {
		pkgs << models.row2version(&row) ?
	}
	return pkgs
}

pub fn (r Versions) add_download(name string) ?models.Version {
	row := r.db.exec_one("UPDATE $versions_table SET downloads = downloads + 1 WHERE name = '$name' RETURNING $versions_fields;") ?
	return models.row2version(row)
}

pub fn (r Versions) delete(name string) ?models.Version {
	row := r.db.exec_one("DELETE FROM $versions_table WHERE name = '$name' RETURNING $versions_fields;") ?
	return models.row2version(row)
}
