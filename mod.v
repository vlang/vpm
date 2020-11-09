module main

const (
	banned_names          = ['NotNite']
	supported_vcs_systems = ['git', 'hg']
)

struct Mod {
	id           int
	name         string
	url          string
	nr_downloads int
	vcs          string = 'git'
}

fn (mut app App) find_all_mods() []Mod {
	rows := app.db.exec('select name, url, nr_downloads, vcs from modules order by nr_downloads desc') or {
		panic(err)
	}
	mut mods := []Mod{}
	for row in rows {
		mods << Mod{
			name: row.vals[0]
			url: row.vals[1]
			nr_downloads: row.vals[2].int()
			vcs: row.vals[3]
		}
	}
	return mods
}

fn (repo ModsRepo) retrieve(name string) ?Mod {
	rows := repo.db.exec_param('select name, url, nr_downloads from modules where name=$1',
		name) or {
		return error(err)
	}
	if rows.len == 0 {
		return error('Found no module with name "$name"')
	}
	row := rows[0]
	mod := Mod{
		name: row.vals[0]
		url: row.vals[1]
		nr_downloads: row.vals[2].int()
		vcs: row.vals[3]
	}
	return mod
}

fn (repo ModsRepo) inc_nr_downloads(name string) {
	repo.db.exec_param('update modules set nr_downloads=nr_downloads+1 where name=$1',
		name)
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
	repo.db.exec_param_many('insert into modules (name, url, vcs) values ($1, $2, $3)',
		[name, url, vcs])
}

fn clean_url(s string) string {
	return s.replace(' ', '-').to_lower()
}
