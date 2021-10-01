module app

import pg
import vweb
import config
import models
import repository
import service

struct App {
	vweb.Context
mut:
	db   &service.Services
	user models.User
	// github integration
	// auth token manager
}

fn new(services service.Services) App {
	mut app := App{
		db: &services
	}

	if !app.handle_static('./static', true) {
		panic('`static` folder does not exist')
	}

	return app
}

pub fn run(config_file string) ? {
	cfg := config.new(config_file) ?
	// db := sqlite.connect(cfg.sqlite.path) ?
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
	vweb.run(app, cfg.http.port)
}
