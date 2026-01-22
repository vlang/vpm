module main

import veb
import config
import entity { Category, Package, User }
import db.pg
import usecase.package
import lib.storage
import usecase.user
import time
import net.urllib
import repo

pub struct Context {
	veb.Context
pub mut:
	// Request-specific data moved here
	cur_user User
	title    string
}

@[heap]
pub struct App {
	veb.StaticHandler
	veb.Middleware[Context]
	config config.Config
pub mut:
	// Global/Shared data stays here
	db      pg.DB
	storage storage.Provider

	// Shared cache data (Requires synchronization if updated concurrently,
	// but assuming single-threaded worker or simple reads for now)
	nr_packages               &string = unsafe { nil }
	categories                []Category
	new_packages              []Package
	recently_updated_packages []Package
	most_downloaded_packages  []Package
	last_update               &time.Time = unsafe { nil }
}

// Helper accessors now take the App (global)
fn (app &App) packages() package.UseCase {
	return package.UseCase{
		categories: repo.categories(app.db)
		packages:   repo.packages(app.db)
		users:      repo.users(app.db)
	}
}

fn (app &App) users() user.UseCase {
	return user.UseCase{
		users: repo.users(app.db)
	}
}

// Logic checks now operate on Context
fn (mut ctx Context) is_logged_in() bool {
	return ctx.cur_user.username != ''
}

// Template helper
fn less_than(i int, value int) bool {
	return i < value
}
