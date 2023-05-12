module main

import time

const banned_names = ['xxx']

const supported_vcs_systems = ['git', 'hg']

struct Package {
	id            int       [primary; sql: serial]
	name          string    [unique]
	description   string
	documentation string
	url           string
	nr_downloads  int
	vcs           string = 'git'
	user_id       int
	author        User      [fkey: 'id']
	stars         int
	downloads     int
	is_flatten    bool // No need to mention author of package, example `ui`
	updated_at    time.Time = time.now()
	created_at    time.Time = time.now()
}

fn (mut app App) find_all_packages() []Package {
	pkgs := sql app.db {
		select from Package order by nr_downloads desc
	} or { [] }
	println('all pkgs ${pkgs.len}')
	return pkgs
}

fn (mut app App) find_all_packages_by_query(query string) []Package {
	q := '%' + query + '%'
	pkgs := sql app.db {
		select from Package where name like q order by nr_downloads desc
	} or { [] }
	println('found pkgs by query "${q}": ${pkgs.len}')
	return pkgs
}

fn (mut app App) nr_packages_by_this_user(user_id int) int {
	nr_pkgs := sql app.db {
		select count from Package where user_id == user_id
	} or { 0 }
	return nr_pkgs
}

fn (mut app App) find_user_packages(user_id int) []Package {
	mod := sql app.db {
		select from Package where user_id == user_id order by nr_downloads desc
	} or { [] }
	return mod
}

fn (app &App) retrieve_package(name string) !Package {
	rows := sql app.db {
		select from Package where name == name
	}!

	if rows.len == 0 {
		return error('Found no module with name "${name}"')
	}
	return rows[0]
}

fn (app &App) inc_nr_downloads(name string) {
	sql app.db {
		update Package set nr_downloads = nr_downloads + 1 where name == name
	} or {}
}

fn (app &App) insert_module(mod Package) {
	for bad_name in banned_names {
		if mod.name.contains(bad_name) {
			return
		}
	}
	if mod.url.contains(' ') || mod.url.contains('%') || mod.url.contains('<') {
		return
	}
	if mod.vcs !in supported_vcs_systems {
		return
	}
	sql app.db {
		insert mod into Package
	} or {}
}

fn clean_url(s string) string {
	return s.replace(' ', '-').to_lower()
}

pub fn (p Package) format_name() string {
	return p.name
}

pub fn (app &App) package_belongs_to_cur_user(p Package) bool {
	return p.user_id == app.cur_user.id
}
