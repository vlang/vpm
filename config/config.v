module config

import os
import toml

pub struct Config {
pub mut:
	http HTTPConfig
	pg   PGConfig
}

pub struct HTTPConfig {
pub mut:
	port int = 8080
}

pub struct PGConfig {
pub mut:
	host     string = 'localhost'
	port     int    = 5432
	user     string = 'postgres'
	password string = 'postgres'
	db_name  string = 'vpm'
}

pub fn new(path string) ?Config {
	if !os.exists(path) {
		return error('config file does not exist')
	}

	doc := toml.parse_file(path) ?

	return Config{
		http: HTTPConfig{
			port: doc.value('http.port').int()
		}
		pg: PGConfig{
			host: doc.value('postgres.host').string()
			port: doc.value('postgres.port').int()
			user: doc.value('postgres.user').string()
			password: doc.value('postgres.password').string()
			db_name: doc.value('postgres.db_name').string()
		}
	}
}

pub fn generate(path string) ? {
	return error('not implemented')
}
