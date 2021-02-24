module main

import sqlite

struct Package {
	id           int
	author_id    int
	name         string
	// TODO: Figure out way to deal with many versions (releases)
	// Maybe create PackageVersion that contains info about release
	version      string
	description  string
	tags         string
	dependencies string
	license      string
	repo_url     string
	nr_downloads int
}

fn package_from_row(row sqlite.Row) Package {
	return Package{
		id: row.vals[0].int()
		author_id: row.vals[1].int()
		name: row.vals[2]
		version: row.vals[3]
		description: row.vals[4]
		tags: row.vals[5]
		dependencies: row.vals[6]
		license: row.vals[7]
		repo_url: row.vals[8]
		nr_downloads: row.vals[9].int()
	}
}

fn (mut app App) get_package(id int) ?Package {
	// Doing it by hands because we need control over errors
	row := app.db.exec_one('select from Package where id=${id}') or {
		return error('sql error: ${err}')
	}
	return package_from_row(row)
}

fn (mut app App) get_package_by_author(id int) ?Package {
	row := app.db.exec_one('select from Package where author_id=${id}') or {
		return error('sql error: ${err}')
	}
	return package_from_row(row)
}

fn (mut app App) get_package_by_name(name string) ?Package {
	row := app.db.exec_one('select from Package where name=${name}') or {
		return error('sql error: ${err}')
	}
	return package_from_row(row)
}

fn (mut app App) get_packages(limit int, offset int) ?[]Package {
	rows, code := app.db.exec('select from Package order by nr_downloads desc limit ${limit} offset ${offset}')
	if code != 0 {
		return error('sql result code ${code}')
	}
	mut packages := []Package{}
	for row in rows {
		packages << package_from_row(row)
	}
	return packages
}

fn (mut app App) get_all_packages() ?[]Package {
	rows, code := app.db.exec('select from Package order by nr_downloads desc')
	if code != 0 {
		return error('sql result code ${code}')
	}
	mut packages := []Package{}
	for row in rows {
		packages << package_from_row(row)
	}
	return packages
}

fn (mut app App) insert_package(pkg Package) {
	app.db.insert(pkg)
}

fn (mut app App) inc_nr_downloads(id string) ? {
	code := app.db.exec_none('update Package set nr_downloads=nr_downloads+1 where id=${id}')
	if code != 0 {
		return error('sql result code ${code}')
	}
}

fn (mut app App) delete_package(id string) ? {
	code := app.db.exec_none('delete from Package where id=${id}')
	if code != 0 {
		return error('sql result code ${code}')
	}
}
