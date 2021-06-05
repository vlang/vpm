module app

import sqlite
import nedpals.vex.picoserver
import vpm.config
import vpm.repository
import vpm.service

pub fn run(config_file string) ? {
	db := sqlite.connect(':memory:') ?
	repos := repository.new_repositories(db)
	services := service.new_services(repos: repos)
	handler := new_handler(services)
	router := handler.init()
	picoserver.serve(router, 8080)
}
