module main

import vweb
import db.pg
import config
import entity { User }
import os
import repo
import time

const max_package_url_len = 75

const config_file = './config.toml'

fn main() {
	conf := config.parse_file(config_file)!

	db := pg.connect(pg.Config{
		host: conf.pg.host
		dbname: conf.pg.db
		user: conf.pg.user
		password: conf.pg.password
		port: conf.pg.port
	})!

	defer {
		db.close()
	}

	repo.migrate(db)!

	nr := 'packages'
	upd := time.unix(0)

	mut app := &App{
		config: conf
		db: db
		title: 'vpm'
		nr_packages: &nr
		last_update: &upd
	}

	if conf.is_dev {
		app.cur_user = User{
			username: conf.dev_user
			is_admin: true
		}
	}

	app.mount_static_folder_at(os.resource_abs_path('./static'), '/')
	vweb.run_at(app, port: conf.http.port, nr_workers: 1)!
}
