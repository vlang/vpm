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

	mut packages_use_case := &package.UseCase{
		packages: &repo.PackagesRepo{
			db: db
		}
	}

	mut users_use_case := &user.UseCase{
		users: &repo.UsersRepo{
			db: db
		}
	}

	mut app := &App{
		db: db
		config: conf
		packages: packages_use_case
		users: users_use_case
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
