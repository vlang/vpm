module main

import vweb
import db.pg
import config
import repo
import entity { Package, User }
import usecase.package
import usecase.user
import os

const max_package_url_len = 75

struct App {
	vweb.Context
	config config.Config [vweb_global]
pub mut:
	db                        pg.DB           [vweb_global]
	cur_user                  User            [vweb_global]
	packages                  package.UseCase [vweb_global]
	users                     user.UseCase    [vweb_global]
	title                     string          [vweb_global]
	nr_packages               int
	recently_updated_packages []Package
	most_downloaded_packages  []Package
	new_packages              []Package
}

const config_file = './config.toml'

fn main() {
	conf := config.parse_file(config_file) or {
		println(err)
		exit(1)
	}

	db := pg.connect(pg.Config{
		host: conf.pg.host
		dbname: conf.pg.db
		user: conf.pg.user
		password: conf.pg.password
		port: conf.pg.port
	}) or { panic(err) }

	defer {
		db.close()
	}

	mut packages_use_case := &package.UseCase{
		packages: repo.new_packages(db)!
	}

	mut users_use_case := &user.UseCase{
		users: repo.new_users(db)!
	}

	mut app := &App{
		db: db
		config: conf
		packages: packages_use_case
		users: users_use_case
	}

	if conf.is_dev {
		app.cur_user = User{
			username: conf.dev_user
			is_admin: true
		}
	}

	app.mount_static_folder_at(os.resource_abs_path('./static'), '/')
	vweb.run(app, conf.http.port)
}
