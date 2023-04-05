module main

import vweb
import db.pg
import json
// import rand
// import rand.seed
import os
import entity
import config

struct App {
	vweb.Context
	gh_client_id     string [vweb_global]
	gh_client_secret string [vweb_global]
pub mut:
	db          pg.DB [vweb_global]
	cur_user    User  [vweb_global]
	nr_packages int
}

const max_name_len = 35

const config_file = './config.toml'

const basic_categories = [
	Category{
		name: 'Command line tools'
	},
	Category{
		name: 'Networking'
	},
	Category{
		name: 'Game development'
	},
	Category{
		name: 'Web programming'
	},
]

const new_packages = [
	entity.FullPackage{
		Package: entity.Package{
			id: 1
			name: 'treplo'
			description: 'Placeholder'
			stars: 3
		}
		author: entity.User{
			username: 'Terisback'
		}
	},
]

const most_downloaded_packages = [
	entity.FullPackage{
		Package: entity.Package{
			id: 1
			name: 'treplo'
			description: 'Placeholder'
			stars: 3
		}
		author: entity.User{
			username: 'Terisback'
		}
	},
]

const recently_updated_packages = [
	entity.FullPackage{
		Package: entity.Package{
			id: 1
			name: 'treplo'
			description: 'Placeholder'
			stars: 3
		}
		author: entity.User{
			username: 'Terisback'
		}
	},
]

fn main() {
	// is_dev := os.args.contains('dev')
	conf := config.parse_file(config_file) or {
		println(err)
		exit(1)
	}
	// s := seed.time_seed_array(2)
	// s.seed([seed[0], seed[1]])
	mut app := &App{
		db: pg.connect(pg.Config{
			host: conf.pg.host
			dbname: conf.pg.db
			user: conf.pg.user
			password: conf.pg.password
		}) or { panic(err) }
		// gh_client_id: dbconf.github_client_id
		// gh_client_secret: dbconf.github_client_secret
	}

	sql app.db {
		create table Package
	}!
	sql app.db {
		create table User
	}!

	if conf.is_dev {
		app.cur_user = User{
			name: 'Test user'
			username: 'test_user'
			is_admin: true
		}
	}

	// app.serve_static('/img/github.png', 'img/github.png')
	vweb.run(app, conf.http.port)
}

struct DbConfig {
	host                 string
	dbname               string
	user                 string
	github_client_id     string
	github_client_secret string
	// password string
}

pub fn (mut app App) before_request() {
	app.nr_packages = sql app.db {
		select count from Package
	} or { 0 }
}

pub fn (mut app App) index() vweb.Result {
	categories := []Category{}
	app.set_cookie(
		name: 'vpm'
		value: '777'
	)
	your_packages := app.find_user_packages(app.cur_user.id)
	// mods := app.find_all_mods()
	return $vweb.html()
}

pub fn (mut app App) new() vweb.Result {
	// app.auth()
	logged_in := app.cur_user.name != ''
	println('new() loggedin: ${logged_in}')
	return $vweb.html()
}

pub fn (mut app App) is_logged_in() bool {
	println('loggedin() ${app.cur_user}')
	return app.cur_user.name != ''
}

[post]
pub fn (mut app App) create_module(name string, description string, vcs string) vweb.Result {
	// app.auth()
	name_lower := name.to_lower()
	println('CREATE name="${name}"')
	if app.cur_user.name == '' || !is_valid_mod_name(name_lower) {
		app.error('not valid mod name curuser="${app.cur_user.name}"')
		return app.redirect('/new')
	}
	url := app.form['url'].replace('<', '&lt;')
	println('CREATE url="${url}"')
	if !url.starts_with('github.com/') && !url.starts_with('http://github.com/')
		&& !url.starts_with('https://github.com/') {
		app.error('wrong url format')
		return app.redirect('/new')
	}
	println('CREATE url="${url}"')
	vcs_ := if vcs == '' { 'git' } else { vcs }
	if vcs_ !in supported_vcs_systems {
		app.error('Unsupported vcs: ${vcs}')
		return app.redirect('/new')
	}
	app.insert_module(Package{
		name: app.cur_user.username + '.' + name.limit(max_name_len)
		url: url.limit(50)
		description: description
		vcs: vcs_.limit(3)
		user_id: app.cur_user.id
	})
	return app.redirect('/')
}

['/delete_package/:package_id'; post]
pub fn (mut app App) delete_package(package_id int) vweb.Result {
	if !app.is_logged_in() {
		return app.ok('ok')
	}
	sql app.db {
		delete from Package where id == package_id && user_id == app.cur_user.id
	} or {}
	return app.ok('ok')
}

pub fn (app &App) format_nr_packages() string {
	if app.nr_packages == 1 {
		return '${app.nr_packages} package'
	}
	return '${app.nr_packages} packages'
}
