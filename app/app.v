module app

import pg
import web
import app.config
import models
import repository
import service

struct App {
	web.Context
pub mut:
	services service.Services [frak_concurrency]
	user     models.User
	// github integration
	// auth token manager
}

fn new(services service.Services) App {
	mut app := App{
		services: services
	}

	// if !app.handle_static('./static', true) {
	// 	panic('`static` folder does not exist')
	// }

	return app
}

pub fn run(config_file string) ? {
	cfg := config.parse_file(config_file) ?
	db := pg.connect(pg.Config{
		host: cfg.pg.host
		port: cfg.pg.port
		user: cfg.pg.user
		password: cfg.pg.password
		dbname: cfg.pg.db_name
	}) ?
	repos := repository.new_repositories(db)
	services := service.new_services(repos: repos)
	app := new(services)

	mut router := web.new(app, web.Config{}) ?
	router.listen(':$cfg.http.port') ?
}

fn (mut app App) index() web.Result {
	nr_packages := app.services.packages.get_packages_count() or {
		println(err)
		0
	}
	packages := app.services.packages.get_most_downloadable() or { []models.Package{} }
	return app.text(.ok, nr_packages.str() + packages.str())
}
