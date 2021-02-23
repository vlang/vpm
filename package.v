module main

struct Package {
	id           int
	author_id    int
	name         string
	version      string
	description  string
	tags         []string
	dependencies []string
	license      string
	repo_url     string
	author       User
	nr_downloads int
	vcs          string = 'git'
}

pub fn (mut app App) insert_package(pkg Package) {
	sql app.db {
		insert pkg into Package
	}
}

pub fn (mut app App) delete_package(pkg Package) {
	sql app.db {
		insert pkg into Package
	}
}
