module main

import sqlite
import rand

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

fn (mut app App) get_some_random_package_info(count int) []PackageInfo {
	mut arr := []PackageInfo{}
	for _ in 1..count {
		arr << app.get_random_package_info()
	}
	return arr
}

fn (mut app App) get_random_package_info() PackageInfo {
	names := [
		"markdown",
		"terisback.treplo",
		"nedpals.vex",
		"nedpals.jsonrpc",
		"terisback.discordv",
		"lydiandy.vast",
		"vmarkdown",
		"some.random",
		"nsauzede.vsdl2",
		"thecodrr.crayon",
		"damienfamed75.vraylib",
		"christopherzimmerman.vnum",
		"duarteroso.vglfw"
	]
	tags := [
		"net",
		"log",
		"logging",
		"cli",
		"discord",
		"api",
		"concurrency"
	]
	mut pac_tags := []Tag{}
	for _ in 0..rand.intn(4)+2 {
		pac_tags << Tag{
			name: tags[rand.intn(tags.len-1)]
		}
	}
	return PackageInfo{
		name: names[rand.intn(names.len-1)]
		description: 'Logging library similar to logrus '.repeat(rand.intn(5)+1)
		version: 'v${rand.intn(2)}.${rand.intn(23)}.${rand.intn(12)}'
		tags: pac_tags
		nr_downloads: rand.intn(1000)
		stars: rand.intn(100)
		last_updated: rand.intn(7).str() + ' days ago'
	}
}

// get package info from package id
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
