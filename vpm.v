module main

import time
import vweb
import sqlite

const (
	http_port = 3000
)

struct App {
	vweb.Context
mut:
	started_at u64
	db sqlite.DB
	logged_in bool
	user User
}

fn main() {
	vweb.run<App>(http_port)
}

pub fn (mut app App) init_once() {
	app.started_at = time.now().unix
	app.db = sqlite.connect('vpm.sqlite') or {
		println('failed to connect to db')
		panic(err)
	}
	app.create_tables()

	app.handle_static('./static/assets/')
	app.handle_static('./static/css/')
	//app.serve_static('/reset.css', './static/css/reset.css', 'text/css')
	//app.serve_static('/main.css', './static/css/main.css', 'text/css')
}

// Global middleware
pub fn (mut app App) init() {
	app.logged_in = app.logged_in()
	app.user = User{}
	if app.logged_in {
		app.user = app.get_user_from_cookies() or {
			app.logged_in = false
			User{}
		}
	}
}

pub fn (mut app App) get_user_from_cookies() ?User {
	return User{}
}

pub fn (mut app App) index() vweb.Result {
	nr_packages := 140
	new_packages := []Mod{}
	most_downloaded_packages := []Mod{}
	recently_updated_packages := []Mod{}
	most_recent_downloads_packages := []Mod{}
	popular_tags := []Mod{}
	popular_categories := []Mod{}
	return $vweb.html()
}