module main

const banned_names = ['xxx']

const supported_vcs_systems = ['git', 'hg']

struct Mod {
	id           int    [primary; sql: serial]
	name         string
	description  string
	url          string
	nr_downloads int
	vcs          string = 'git'
	user_id      int
	author       User   [fkey: 'id']
	stars        int
	downloads    int
	is_flatten   bool // No need to mention author of package, example `ui`
}

fn (mut app App) find_all_mods() []Mod {
	mods := sql app.db {
		select from Mod order by nr_downloads desc
	}
	return mods
}

fn (mut app App) find_user_packages(user_id int) []Mod {
	mod := sql app.db {
		select from Mod where user_id == user_id order by nr_downloads desc
	}
	return mod
}

fn (app &App) retrieve(name string) !Mod {
	rows := sql app.db {
		select from Mod where name == name
	} or { panic(err) }

	if rows.len == 0 {
		return error('Found no module with name "${name}"')
	}
	return rows[0]
}

fn (app &App) inc_nr_downloads(name string) {
	sql app.db {
		update Mod set nr_downloads = nr_downloads + 1 where name == name
	}
}

fn (app &App) insert_module(mod Mod) {
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
		insert mod into Mod
	}
}

fn clean_url(s string) string {
	return s.replace(' ', '-').to_lower()
}

pub fn (package Mod) format_name() string {
	return if package.is_flatten {
		package.name
	} else {
		'${package.author.username}.${package.name}'
	}
}
