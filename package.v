module main

import sqlite

struct Package {
	id           int
	author_id    int
	name         string
	version      string
	description  string
	tags         string
	dependencies string
	license      string
	repo_url     string
	nr_downloads int
}

// Used in page rendering
struct PackageInfo {
	id           int
	author_id    int
	name         string
	uri          string
	version      string
	versions     []Version
	categories   []Category
	last_updated string
	description  string
	tags         []Tag
	dependencies []Dependency
	license      string
	repo_url     string
	stars        int
	nr_downloads int
}

fn (mut app App) repo_markdown(repo_url string) string {
	return '<p>Repo Markdown</p>'
}

struct Version {
	id          int
	package_id  string
	name        string
	uri         string
	release_url string
	date        string
}

struct Tag {
	id          int
	name        string
	uri         string
	nr_packages int
}

struct Category {
	id   int
	name string
	uri  string
}

struct Dependency {
	id      int
	name    string
	version string
	uri     string
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

fn (mut app App) get_package_info(id int) ?PackageInfo {
	return PackageInfo{}
}

fn (mut app App) get_package(id int) ?Package {
	// Doing it by hands because we need control over errors
	row := app.db.exec_one('select from Package where id=$id') or {
		return error('sql error: $err')
	}
	return package_from_row(row)
}

fn (mut app App) get_package_by_author(id int) ?Package {
	row := app.db.exec_one('select from Package where author_id=$id') or {
		return error('sql error: $err')
	}
	return package_from_row(row)
}

fn (mut app App) get_package_by_name(name string) ?Package {
	row := app.db.exec_one('select from Package where name=$name') or {
		return error('sql error: $err')
	}
	return package_from_row(row)
}

fn (mut app App) get_packages(limit int, offset int) ?[]Package {
	rows, code := app.db.exec('select from Package order by nr_downloads desc limit $limit offset $offset')
	if code != 0 {
		return error('sql result code $code')
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
		return error('sql result code $code')
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
	code := app.db.exec_none('update Package set nr_downloads=nr_downloads+1 where id=$id')
	if code != 0 {
		return error('sql result code $code')
	}
}

fn (mut app App) delete_package(id string) ? {
	code := app.db.exec_none('delete from Package where id=$id')
	if code != 0 {
		return error('sql result code $code')
	}
}
