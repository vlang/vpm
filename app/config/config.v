module config

import os
import toml

pub struct Config {
pub mut:
	gh   GHConfig
	http HTTPConfig
	pg   PGConfig
}

pub struct GHConfig {
pub mut:
	client_id string
	secret    string
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

pub fn parse_file(path string) ?Config {
	if !os.exists(path) {
		return error('config file does not exist')
	}

	data := os.read_file(path) ?
	return parse(data)
}

pub fn parse(data string) ?Config {
	cfg := toml.parse_text(data) ?

	return Config{
		gh: GHConfig{
			client_id: cfg.value('github.client_id').string()
			secret: cfg.value('github.secret').string()
		}
		http: HTTPConfig{
			port: cfg.value('http.port').default_to(8080).int()
		}
		pg: PGConfig{
			host: cfg.value('postgres.host').default_to('localhost').string()
			port: cfg.value('postgres.port').default_to(5432).int()
			user: cfg.value('postgres.user').default_to('postgres').string()
			password: cfg.value('postgres.password').default_to('postgres').string()
			db_name: cfg.value('postgres.db_name').default_to('vpm').string()
		}
	}
}

pub fn generate(path string) ? {
	return error('not implemented')
}
