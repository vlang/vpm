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

fn (repo Versions) dependencies(id int) ?[]int {
	// TODO: Sort by downloads (join with versions table or smth)
	rows := repo.db.exec('SELECT dependency_id FROM $version_dependencies_table WHERE version_id = $id;')?
	return rows.map(fn (row pg.Row) int {
		return row.vals[0].int()
	})
}

pub fn (repo Versions) create(version models.Version) ?models.Version {
	row := repo.db.exec_one('INSERT INTO $models.versions_table ' +
		'(package_id, release_date, semver, download_url) ' + 'VALUES' + '(' +
		version.package_id.str() + ',' + version.release_date.unix_time().str() + ", '" +
		[version.semver, version.download_url].join("', '") + "') RETURNING $models.version_fields;")?
	return models.row2version(row)
}

pub fn (repo Versions) get_by_id(id int) ?models.Version {
	query := 'SELECT $models.version_fields FROM $models.versions_table WHERE id = $id;'
	row := repo.db.exec_one(query)?
	return models.row2version(row)
}

pub fn (repo Versions) get(package_id int, tag string) ?models.Version {
	query := "SELECT $models.version_fields FROM $models.versions_table WHERE package_id = $package_id AND tag = '$tag';"
	row := repo.db.exec_one(query)?
	return models.row2version(row)
}

pub fn (repo Versions) get_by_package(package_id int) ?[]models.Version {
	query := 'SELECT $models.version_fields FROM $models.versions_table WHERE package_id = $package_id ORDER BY release_date DESC;'
	rows := repo.db.exec(query)?

	if rows.len == 0 {
		return not_found()
	}

	mut versions := []models.Version{}
	for row in rows {
		versions << models.row2version(&row)?
	}

	return versions
}

pub fn (repo Versions) get_by_ids(ids ...int) ?[]models.Version {
	mut query_ids := strings.new_builder(16)
	for i in ids {
		query_ids.write_string('$i,')
	}
	query_ids.cut_last(1)

	query := 'SELECT $models.version_fields FROM $models.versions_table WHERE id IN ($query_ids.str());'
	rows := repo.db.exec(query)?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Version{cap: rows.len}
	for row in rows {
		pkgs << models.row2version(&row)?
	}
	return pkgs
}

pub fn (repo Versions) add_download(package_id int) ?models.Version {
	row := repo.db.exec_one('UPDATE $models.versions_table SET downloads = downloads + 1 WHERE package_id = $package_id RETURNING $models.version_fields ;')?
	return models.row2version(row)
}

pub fn (repo Versions) delete(id int) ?models.Version {
	row := repo.db.exec_one('DELETE FROM $models.versions_table WHERE id = $id RETURNING $models.version_fields;')?
	return models.row2version(row)
}

pub fn (repo Versions) versions(package_id int) ?[]models.Version {
	rows := repo.db.exec('SELECT $models.version_fields FROM $models.versions_table WHERE package_id = $package_id ORDER BY release_date DESC;')?

	if rows.len == 0 {
		return not_found()
	}

	mut pkgs := []models.Version{cap: rows.len}
	for row in rows {
		pkgs << models.row2version(&row)?
	}
	return pkgs
}

pub fn (repo Versions) latest_version(package_id int) ?models.Version {
	query := 'SELECT $models.version_fields FROM $models.versions_table WHERE package_id = $package_id ORDER BY release_date DESC LIMIT 1;'
	row := repo.db.exec_one(query)?
	return models.row2version(row)
}
