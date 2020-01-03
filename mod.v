module main

import time

struct Mod {
	id int 
	name string 
	url string
	nr_downloads int 
}


fn (app mut App) find_all_mods() []Mod {
	rows := app.db.exec(' 
select name, url, nr_downloads 
from modules 
order by nr_downloads desc')
	mut mods := []Mod 
	for row in rows {
		mods << Mod {
			name: row.vals[0]
			url: row.vals[1]
			nr_downloads: row.vals[2].int() 
		}
	}
	return mods 
}

fn (repo ModsRepo) retrieve(name string) ?Mod { 
	rows := repo.db.exec_param('select name, url, nr_downloads from modules where name=$1', name) 
	if rows.len == 0 {
		return error('no posts')
	}
	row := rows[0]
	post := Mod {
		name: row.vals[0]
		url: row.vals[1]
		nr_downloads: row.vals[2].int() 
	}
	return post
}

fn (repo ModsRepo) inc_nr_downloads(name string) {  
	repo.db.exec_param('update modules set nr_downloads=nr_downloads+1 where name=$1', name) 
} 

const (
	banned_names = ['NotNite'] 
) 

fn (repo ModsRepo) insert_module(name, url string) { 
	for bad_name in banned_names {
		if name.contains(bad_name) { return } 
	} 
	if url.contains(' ') || url.contains('%') || url.contains('<') {
		return 
	} 
	//repo.db.exec('insert into modules (name, url) values (\'HI\', \'LOL\')') 
	repo.db.exec_param2('insert into modules (name, url) values ($1, $2)', name, url) 
	//repo.db.exec_param2('insert into modules (name, url) values ($1, $2)', name, url) 
} 

fn clean_url(s string) string {
        return s.replace(' ', '-').to_lower() 
} 
