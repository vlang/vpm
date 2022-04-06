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

// fn (repo ModsRepo) retrieve(name string) ?Mod {
fn (app &App) retrieve(name string) ?Mod {
	rows := app.db.exec_param('select name, url, nr_downloads, vcs, description from "Mod" where name=$1',
		name) or { return err }
	if rows.len == 0 {
		return error('Found no module with name "$name"')
	}
	row := rows[0]
	mod := Mod{
		name: row.vals[0]
		url: row.vals[1]
		nr_downloads: row.vals[2].int()
		vcs: row.vals[3]
		description: row.vals[4]
	}

	/*
	mod := sql repo.db {
		select from Mod where name == name limit 1
	}
	*/
	return mod
}

fn (app &App) inc_nr_downloads(name string) {
	sql app.db {
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
