module main

import vweb
import pg
import json
// import rand
// import rand.seed
import os

const (
	port = 8091
)

struct ModsRepo {
	db pg.DB
}

struct App {
	vweb.Context
pub mut:
	db        pg.DB
	cur_user  User
	mods_repo ModsRepo
}

fn main() {
	// s := seed.time_seed_array(2)
	// s.seed([seed[0], seed[1]])
	txt := os.read_file('dbconf.json') ?
	println(txt)
	dbconf := json.decode(DbConfig, txt) or {
		println('failed to decode dbconf.json: $err')
		return
	}
	// dbconf := json.decode(DbConfig, os.read_file('dbconf.json') ?) ?
	mut app := &App{
		db: pg.connect(pg.Config{
			host: dbconf.host
			dbname: dbconf.dbname
			user: dbconf.user
		}) or { panic(err) }
		// app.db = db
		// app.cur_user = User{}
	}
	app.mods_repo = ModsRepo{app.db}

	// app.serve_static('/img/github.png', 'img/github.png')
	vweb.run(app, port)
}

struct DbConfig {
	host   string
	dbname string
	user   string
	// password string
}

pub fn (mut app App) init() {
}

pub fn (mut app App) index() vweb.Result {
	app.set_cookie(
		name: 'vpm'
		value: '777'
	)
	mods := app.find_all_mods()
	println(123) // TODO remove, won't work without it
	return $vweb.html()
}

pub fn (mut app App) new() vweb.Result {
	app.auth()
	logged_in := app.cur_user.name != ''
	println('new() loggedin: $logged_in')
	return $vweb.html()
}

const (
	max_name_len = 10
)

fn is_valid_mod_name(s string) bool {
	if s.len > max_name_len || s.len < 2 {
		return false
	}
	for c in s {
		// println(c.str())
		if !(c >= `A` && c <= `Z`) && !(c >= `a` && c <= `z`) && !(c >= `0` && c <= `9`) && c != `.` {
			return false
		}
	}
	return true
}

[post]
pub fn (mut app App) create_module(name string, description string, vcs string) vweb.Result {
	app.auth()
	name_lower := name.to_lower()
	println('CREATE name="$name"')
	if app.cur_user.name == '' || !is_valid_mod_name(name_lower) {
		println('not valid mod name curuser="$app.cur_user.name"')
		return app.redirect('/')
	}
	url := app.form['url'].replace('<', '&lt;')
	println('CREATE url="$url"')
	if !url.starts_with('github.com/') && !url.starts_with('http://github.com/')
		&& !url.starts_with('https://github.com/') {
		println('NOT GITHUb')
		return app.redirect('/')
	}
	println('CREATE url="$url"')
	vcs_ := if vcs == '' { 'git' } else { vcs }
	if vcs_ !in supported_vcs_systems {
		println('Unsupported vcs: $vcs')
		return app.redirect('/')
	}
	app.mods_repo.insert_module(app.cur_user.name + '.' + name.limit(max_name_len), url.limit(50),
		vcs_.limit(3))
	return app.redirect('/')
}

['/mod/:name']
pub fn (mut app App) mod(name string) vweb.Result {
	// name := app.get_mod_name()
	println('mod name=$name')
	mymod := app.mods_repo.retrieve(name) or { return app.redirect('/') }
	// comments := app.find_comments(id)
	// show_form := true
	return $vweb.html()
}

pub fn (mut app App) jsmod() {
	name := app.req.url.replace('jsmod/', '')[1..]
	println('MOD name=$name')
	app.mods_repo.inc_nr_downloads(name)
	mod := app.mods_repo.retrieve(name) or {
		app.json('404')
		return
	}
	app.json(json.encode(mod))
}

// "/post/:id/:title"
pub fn (app App) get_mod_name() string {
	return app.req.url[5..]
}
