module main

import time
import os
import vweb
import sqlite
import json

const (
	// Port on which the application will run
	http_port = 8080
)

struct App {
	vweb.Context
mut:
	started_at u64
	db         sqlite.DB
	logged_in  bool
	user       User
}

fn main() {
	vweb.run<App>(http_port)
}

// App initialization
pub fn (mut app App) init_once() {
	app.started_at = time.now().unix

	// Connect to database
	app.db = sqlite.connect('vpm.sqlite') or {
		println('failed to connect to db')
		panic(err)
	}
	app.create_tables()

	if client_id == "" {
		eprintln('Please set client id with env variable VPM_GITHUB_CLIENT_ID')
		panic('No github client id is specified')
	}

	if os.getenv('VPM_SKIP_STATIC') !in ['1', 'true'] {
		app.handle_static('./static/', true)
	}
}

// Global middleware
pub fn (mut app App) init() {
	app.logged_in = app.logged_in()
	if app.logged_in {
		app.user = app.get_user_from_cookies() or {
			app.logged_in = false
			User{}
		}
	}
}

// ==Frontend Endpoints==

// Homepage
pub fn (mut app App) index() vweb.Result {
	nr_packages := 149
	new_packages := app.get_some_random_package_info(6)
	most_downloaded_packages := app.get_some_random_package_info(6)
	recently_updated_packages := app.get_some_random_package_info(6)
	most_recent_downloads_packages := app.get_some_random_package_info(6)
	popular_tags := app.get_some_random_package_info(6)
	popular_categories := app.get_some_random_package_info(6)
	return $vweb.html()
}

// Create module
pub fn (mut app App) create() vweb.Result {
	return $vweb.html()
}

// Create module handler
[post]
['/create']
pub fn (mut app App) create_package() vweb.Result {
	if app.logged_in {
		repo_url := app.form['repo_url']

		// TODO: get repo info from git
		package := Package{
			author_id: app.user.id
			name: 'test'
			version: '0.1.0'
			description: 'Test package'
			license: 'MIT'
			repo_url: repo_url
		}
		app.insert_package(package)
		return app.ok('')
	}
	app.error('Not logged in')
	return app.server_error(401)
}

// Browse modules
pub fn (mut app App) browse() vweb.Result {
	// packages := app.get_all_packages() or {
	// 	return app.server_error(500)
	// }
	browse_header := 'All packages'
	packages := app.get_some_random_package_info(20)
	return $vweb.html()
}

// Login endpoint
pub fn (mut app App) login() vweb.Result {
	return app.redirect(app.get_login_link())
}

// Logout endpoint
pub fn (mut app App) logout() vweb.Result {
	app.set_cookie(name: 'id', value: '')
	app.set_cookie(name: 'token', value: '')
	return app.redirect('/')
}

['/:username']
pub fn (mut app App) user(username string) vweb.Result {
	return $vweb.html()
}

['/:username/:package']
pub fn (mut app App) package(username string, package string) vweb.Result {
	current_package := PackageInfo{}
	return $vweb.html()
}

// ==API Endpoints==

// Old module retrive
['/jsmod/:name']
pub fn (mut app App) jsmod(name string) vweb.Result {
	pkg := app.get_package_by_name(name) or {
		app.set_status(404, "Module not found")
		return app.not_found()
	}

	mod := OldPackage{
		id: pkg.id
		name: pkg.name
		url: pkg.repo_url
		nr_downloads: pkg.nr_downloads
		vcs: 'git'
	}
	
	return app.json(json.encode(mod))
}

['/api/:user']
pub fn (mut app App) api_user(user string) vweb.Result {
	mut not_found := false

	mut usr := app.get_user(user.int()) or { // get user by id
		not_found = true
		User{}
	}
	if not_found == false {
		return app.json(json.encode(usr))
	}

	usr = app.get_user_by_name(user) or {
		not_found = true
		User{}
	}
	if not_found == false {
		return app.json(json.encode(usr))
	}

	return app.not_found()
}

['/api/:user/:package']
pub fn (mut app App) api_package(user string, package string) vweb.Result {
	return app.ok('Not implemented')
}	

[delete]
['/api/:user/:package']
pub fn (mut app App) api_package_delete(user string, package string) vweb.Result {
	if !app.user.is_admin {
		// app.send_status(401) // not authorized
		return app.redirect('/')
	}

	app.delete_package('-1') or {println(err)}
	return app.ok('Nice')
}
