module app

import pg
import vweb
import app.config
import repository
import service

[heap]
struct App {
	vweb.Context
pub mut:
	config config.Config [vweb_global]
	services shared service.Services
}

pub fn run(cfg config.Config) ? {
	db := pg.connect(pg.Config{
		host: cfg.pg.host
		port: cfg.pg.port
		user: cfg.pg.user
		password: cfg.pg.password
		dbname: cfg.pg.db_name
	}) ?
	repos := repository.new_repositories(db)
	services := service.new_services(repos: repos)
	mut app := &App{
		config: cfg
		services: services
	}
	app.serve_static('/', './static')
	vweb.run(app, cfg.http.port)
}
