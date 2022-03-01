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
	return App{
		services: services
	}
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
	router.serve_static('/', './static') ?
	router.listen(':$cfg.http.port') ?
}
