module main

import vweb
import db.pg
// import json
// import rand
// import rand.seed
import os
// import entity
import config
import net.http

// gh_client_id     string [vweb_global]
// gh_client_secret string [vweb_global]
struct App {
	vweb.Context
	config config.Config [vweb_global]
pub mut:
	db                        pg.DB     [vweb_global]
	cur_user                  User      [vweb_global]
	nr_packages               int
	recently_updated_packages []Package
	most_downloaded_packages  []Package
	new_packages              []Package
	// Decoded jwt claims, if there is
	// claims &JWTClaims = unsafe { nil }
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
			port: conf.pg.port
		}) or { panic(err) }
		config: conf
		// gh_client_id: dbconf.github_client_id
		// gh_client_secret: dbconf.github_client_secret
	}

	sql app.db {
		create table Package
	}!
	sql app.db {
		create table User
	}!

	if os.args.contains('-migrate') {
		app.migrate_old_modules()!
		exit(0)
	}

	if conf.is_dev {
		app.cur_user = User{
			// name: 'Test user'
			username: 'test_user'
			is_admin: true
		}
	}

	app.serve_static('/css/dist.css', 'css/dist.css')
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
	// println('NR packages ${app.nr_packages}')

	app.recently_updated_packages = sql app.db {
		select from Package order by updated_at desc limit 10
	} or {
		// println(err)
		// exit(0)
		[]
	}

	// println('AAAAA')
	// println(app.recently_updated_packages)

	app.new_packages = sql app.db {
		select from Package order by created_at limit 10
	} or { [] }

	/*
	println('nr_pkgs=${app.new_packages.len}')
	for i, pkg in app.new_packages {
		println('${i}) ${pkg.name}  - user_id:${pkg.user_id}')
		// user := app.retrieve_user(pkg.user_id)
		users := sql app.db {
			select from User where id == pkg.user_id
		} or {
			println(err)
			continue
		}
		println(users)
	}
	*/

	app.most_downloaded_packages = sql app.db {
		select from Package order by nr_downloads limit 10
	} or { [] }

	app.auth()
}

pub fn (mut app App) index() vweb.Result {
	categories := []Category{}
	app.set_cookie(
		name: 'vpm'
		value: '777'
	)
	println('cur user id:${app.cur_user.id}')
	your_packages := app.find_user_packages(app.cur_user.id)
	// println('YOUR PACKAGES')
	// println(your_packages)
	// mods := app.find_all_mods()
	return $vweb.html()
}

pub fn (mut app App) new() vweb.Result {
	// app.auth()
	logged_in := app.cur_user.username != ''
	println('new() loggedin: ${logged_in}')
	return $vweb.html()
}

pub fn (mut app App) is_logged_in() bool {
	println('loggedin() ${app.cur_user}')
	return app.cur_user.username != ''
}

[post]
pub fn (mut app App) create_module(name string, description string, vcs string) vweb.Result {
	// app.auth()
	name_lower := name.to_lower()
	println('CREATE name="${name}"')
	if app.cur_user.username == '' || !is_valid_mod_name(name_lower) {
		app.error('not valid mod name curuser="${app.cur_user.username}"')
		return app.redirect('/new')
	}
	url := app.form['url'].replace('<', '&lt;').limit(50)
	println('CREATE url="${url}"')
	if !url.starts_with('github.com/') && !url.starts_with('http://github.com/')
		&& !url.starts_with('https://github.com/') {
		app.error('wrong url format')
		return app.new()
	}

	if !url.starts_with('https://github.com/${app.cur_user.username}') {
		app.error('You can only submit packages under your GitHub acount "${app.cur_user.username}"')
		return app.new()
	}

	resp := http.get(url) or {
		app.error('Failed to fetch module URL')
		return app.new()
	}
	if resp.status_code == 404 {
		app.error('This module URL does not exist (404)')
		return app.new()
	}

	if app.nr_packages_by_this_user(app.cur_user.id) > 100 {
		app.error('One user can submit no more than 100 modules')
		return app.new()
	}

	println('CREATE url="${url}"')
	vcs_ := if vcs == '' { 'git' } else { vcs }
	if vcs_ !in supported_vcs_systems {
		app.error('Unsupported vcs: ${vcs}')
		return app.redirect('/new')
	}

	// Make sure the URL is unique
	existing := sql app.db {
		select from Package where url == url
	} or { return app.redirect('/new') }
	if existing.len > 0 {
		app.error('This URL has already been submitted')
		return app.new()
	}

	app.insert_module(Package{
		name: app.cur_user.username + '.' + name.limit(max_name_len)
		url: url
		description: description
		vcs: vcs_.limit(3)
		user_id: app.cur_user.id
	})
	return app.redirect('/')
}

['/delete_package/:package_id'; post]
pub fn (mut app App) delete_package(package_id int) vweb.Result {
	if true {
		return app.ok('ok')
	}
	if !app.is_logged_in() {
		return app.ok('ok')
	}
	sql app.db {
		delete from Package where id == package_id && user_id == app.cur_user.id
	} or {}
	return app.ok('ok')
}

['/mod/:name']
pub fn (mut app App) mod(name string) vweb.Result {
	println('mod name=${name}')
	pkg := app.retrieve_package(name) or { return app.redirect('/') }
	return $vweb.html()
}

['/jsmod/:name']
pub fn (mut app App) jsmod(name string) vweb.Result {
	println('jsMOD name=${name}')
	app.inc_nr_downloads(name)
	mod := app.retrieve_package(name) or { return app.json('404') }
	return app.json(mod)
}

pub fn (app &App) format_nr_packages() string {
	if app.nr_packages == 1 {
		return '${app.nr_packages} package'
	}
	return '${app.nr_packages} packages'
}
