module main

import vweb
import db.pg
import config
import repo
import entity
import usecase.package
import usecase.user

struct App {
	vweb.Context
	config config.Config [vweb_global]
pub mut:
	db                        pg.DB            [vweb_global]
	cur_user                  entity.User      [vweb_global]
	packages                  package.UseCase  [vweb_global]
	users                     user.UseCase     [vweb_global]
	nr_packages               int
	recently_updated_packages []entity.Package
	most_downloaded_packages  []entity.Package
	new_packages              []entity.Package
}

const config_file = './config.toml'

const basic_categories = [
	entity.Category{
		name: 'Command line tools'
	},
	entity.Category{
		name: 'Networking'
	},
	entity.Category{
		name: 'Game development'
	},
	entity.Category{
		name: 'Web programming'
	},
]

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

	mut packages := &package.n{
		db: db
	}

	mut app := &App{
		db: db
		config: conf
		packages: packages
	}

	sql app.db {
		create table entity.Package
	}!
	sql app.db {
		create table entity.User
	}!

	if conf.is_dev {
		app.cur_user = entity.User{
			username: conf.dev_user
			is_admin: true
		}
	}

	app.serve_static('/css/dist.css', 'css/dist.css')
	app.serve_static('/favicon.png', 'favicon.png')
	vweb.run(app, conf.http.port)
}

pub fn (mut app App) before_request() {
	app.nr_packages = sql app.db {
		select count from entity.Package
	} or { 0 }

	app.recently_updated_packages = sql app.db {
		select from entity.Package order by updated_at desc limit 10
	} or { [] }

	app.new_packages = sql app.db {
		select from entity.Package order by created_at limit 10
	} or { [] }

	app.most_downloaded_packages = sql app.db {
		select from entity.Package order by downloads limit 10
	} or { [] }

	app.auth()
}

pub fn (mut app App) is_logged_in() bool {
	println('loggedin() ${app.cur_user}')
	return app.cur_user.username != ''
}

pub fn (app &App) format_nr_packages() string {
	if app.nr_packages == 1 {
		return '${app.nr_packages} package'
	}
	return '${app.nr_packages} packages'
}

fn clean_url(s string) string {
	return s.replace(' ', '-').to_lower()
}
