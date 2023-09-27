module main

import vweb
import config
import entity { Category, Package, User }
import db.pg
import usecase.package
import lib.storage
import usecase.user
import repo
import time

struct App {
	vweb.Context
	config config.Config [vweb_global]
pub mut:
	db       pg.DB            [vweb_global]
	title    string           [vweb_global]
	cur_user User             [vweb_global]
	storage  storage.Provider [vweb_global]

	nr_packages               &string    [vweb_global] = unsafe { nil }
	categories                []Category [vweb_global]
	new_packages              []Package  [vweb_global]
	recently_updated_packages []Package  [vweb_global]
	most_downloaded_packages  []Package  [vweb_global]
	last_update               &time.Time [vweb_global] = unsafe { nil }
}

// Whole app middleware
pub fn (mut app App) before_request() {
	// Skip auth for static
	if app.req.url.ends_with('/favicon.png') || app.req.url.ends_with('/dist.css') {
		app.add_header('Cache-Control', 'max-age=86400')
		return
	}

	app.auth()
}

fn (mut app App) packages() package.UseCase {
	return package.UseCase{
		categories: repo.categories(app.db)
		packages: repo.packages(app.db)
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
