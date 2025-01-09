module main

import vweb
import config
import entity { Category, Package, User }
import db.pg
import usecase.package
import lib.storage
import usecase.user
import net.urllib
import repo
import time

struct App {
	vweb.Context
	config config.Config @[vweb_global]
pub mut:
	db       pg.DB            @[vweb_global]
	title    string           @[vweb_global]
	cur_user User             @[vweb_global]
	storage  storage.Provider @[vweb_global]

	nr_packages               &string = unsafe { nil }    @[vweb_global]
	categories                []Category @[vweb_global]
	new_packages              []Package  @[vweb_global]
	recently_updated_packages []Package  @[vweb_global]
	most_downloaded_packages  []Package  @[vweb_global]
	last_update               &time.Time = unsafe { nil } @[vweb_global]
}

// Whole app middleware
pub fn (mut app App) before_request() {
	url := urllib.parse(app.req.url) or { panic(err) }

	// Skip auth for static
	if url.path == '/favicon.png' || url.path.starts_with('/css') || url.path.starts_with('/js') {
		// Set cache for a week
		app.add_header('Cache-Control', 'max-age=604800')
		return
	}

	app.auth()
}

fn (mut app App) packages() package.UseCase {
	return package.UseCase{
		categories: repo.categories(app.db)
		packages:   repo.packages(app.db)
		users:      repo.users(app.db)
	}
}

fn (mut app App) users() user.UseCase {
	return user.UseCase{
		users: repo.users(app.db)
	}
}

fn (mut app App) is_logged_in() bool {
	return app.cur_user.username != ''
}

// used by templates
fn less_than(i int, value int) bool {
	return i < value
}
