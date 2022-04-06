module main

const (
	banned_names          = ['xxx']
	supported_vcs_systems = ['git', 'hg']
)

struct Mod {
	id           int
	name         string
	description  string
	url          string
	nr_downloads int
	vcs          string = 'git'
}

fn (mut app App) find_all_mods() []Mod {
	mods := sql app.db {
		select from Mod order by nr_downloads desc
	}
	return mods
}

fn (repo ModsRepo) retrieve(name string) ?Mod {
	mod := sql repo.db {
		select from Mod where name == name limit 1
	}
	return mod
}

fn (repo ModsRepo) inc_nr_downloads(name string) {
	sql repo.db {
		update Mod set nr_downloads = nr_downloads + 1 where name == name
	}
}

fn (repo ModsRepo) insert_module(name string, url string, vcs string) {
	for bad_name in banned_names {
		if name.contains(bad_name) {
			return
		}
	}
	if url.contains(' ') || url.contains('%') || url.contains('<') {
		return
	}
	if vcs !in supported_vcs_systems {
		return
	}
	mod := Mod{
		name: name
		url: url
		vcs: vcs
	}
	sql repo.db {
		insert mod into Mod
	}
}

fn clean_url(s string) string {
	return s.replace(' ', '-').to_lower()
}
