module main

import veb
import db.pg
import config
import entity { User }
import lib.storage.local
import os
import repo
import time

const max_package_url_len = 75
const config_file = './config.toml'

fn main() {
	conf := config.parse_file(config_file)!

	db := pg.connect(pg.Config{
		host:     conf.pg.host
		dbname:   conf.pg.db
		user:     conf.pg.user
		password: conf.pg.password
		port:     conf.pg.port
	})!

	defer {
		db.close() or {}
	}

	repo.migrate(db)!

	st := local.new(conf.storage_path)!
	nr := 'packages'
	upd := time.unix(0)

	mut app := &App{
		config:      conf
		db:          db
		storage:     st
		nr_packages: &nr
		last_update: &upd
	}

    // Static file handling
	app.mount_static_folder_at(os.resource_abs_path('./static'), '/')!

    
    // Register Middleware (replaces before_request)
	app.use(handler: app.auth_middleware)

	// Run veb
	veb.run[App, Context](mut app, conf.http.port)
}

/*
// Middleware function to replace app.before_request
pub fn auth_middleware(mut ctx Context) bool {
    // Skip auth for static assets handled by veb (optional check, veb usually handles static before middleware)
	if ctx.req.url.contains('/favicon.png') || ctx.req.url.starts_with('/css') || ctx.req.url.starts_with('/js') {
		ctx.res.header.add(.cache_control, 'max-age=604800')
		return true
	}

	// Call the auth logic (moved to auth.v or defined here)
    // We need to call the logic that populates ctx.cur_user
    ctx.auth() 
    
    return true
}
*/
