module main

struct Mod {
	id           int
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

pub fn (mut app App) insert_mod(mod Mod) {
	sql app.db {
		insert mod into Mod
	}
}

