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

	if !os.exists('./static/vpm.css') {
		eprintln('Please compile styles with sass.')
		eprintln('\'sass --recursive ./css/vpm.scss:./static/vpm.css\'')
		panic('No vpm.css file in static')
	}
	app.handle_static('./static/', false)
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

pub fn (mut app App) new() vweb.Result {
	return $vweb.html()
}

pub fn (mut app App) browse() vweb.Result {
	return $vweb.html()
}

pub fn (mut app App) package() vweb.Result {
	return $vweb.html()
}

pub fn (mut app App) user() vweb.Result {
	return $vweb.html()
}