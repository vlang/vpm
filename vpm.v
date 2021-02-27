module main

import time
import os
import vweb
import sqlite

const (
	http_port = 80
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

pub fn (mut app App) init_once() {
	app.started_at = time.now().unix

	// Connect to database
	app.db = sqlite.connect('vpm.sqlite') or {
		println('failed to connect to db')
		panic(err)
	}
	app.create_tables()

	if os.getenv('VPM_SKIP_STATIC') != '1' {
		if !os.exists('./static/vpm.css') {
			eprintln('Please compile styles with sass.')
			eprintln('\'sass --recursive ./css/vpm.scss:./static/vpm.css\'')
			panic('No vpm.css file in static')
		}
		app.handle_static('./static/', false)
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

pub fn (mut app App) index() vweb.Result {
	nr_packages := 140
	new_packages := []Package{}
	most_downloaded_packages := []Package{}
	recently_updated_packages := []Package{}
	most_recent_downloads_packages := []Package{}
	popular_tags := []Package{}
	popular_categories := []Package{}
	return $vweb.html()
}

pub fn (mut app App) create() vweb.Result {
	return $vweb.html()
}

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

pub fn (mut app App) browse() vweb.Result {
	// packages := app.get_all_packages() or {
	// 	return app.server_error(500)
	// }
	browse_header := "All packages"
	packages := []PackageInfo{}
	return $vweb.html()
}

pub fn (mut app App) login() vweb.Result {
	return app.redirect(app.get_login_link())
}

pub fn (mut app App) logout() vweb.Result {
	app.set_cookie(name: 'id', value: '')
	app.set_cookie(name: 'token', value: '')
	return app.redirect('/')
}

['/user/:username']
pub fn (mut app App) user(username string) vweb.Result {
	return $vweb.html()
}

['/:package']
pub fn (mut app App) package(package string) vweb.Result {
	package := PackageInfo{}
	return $vweb.html()
}