module app

import sqlite
import vweb
import config
import models
import repository
import service

struct App {
	vweb.Context
mut:
	services service.Services
	user     models.User
	// github integration
	// auth token manager
}

pub fn new(services service.Services) App {
	mut app := App{
		services: services
	}

	if !app.handle_static('./static', true){
		panic('folder does not exist or app already end its work')
	}

	return app
}

pub fn run(config_file string) ? {
	cfg := config.new(config_file) ?
	db := sqlite.connect(cfg.sqlite.path) ?
	repos := repository.new_repositories(db)
	services := service.new_services(repos: repos)
	app := new(services)
	vweb.run(app, cfg.http.port)
}
