module config

import os
import toml
import utils

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
			port: utils.default(cfg.value('http.port').int(), 8080)
		}
		pg: PGConfig{
			host: utils.default(cfg.value('postgres.host').string(), 'localhost')
			port: utils.default(cfg.value('postgres.port').int(), 5432)
			user: utils.default(cfg.value('postgres.user').string(), 'postgres')
			password: utils.default(cfg.value('postgres.password').string(), 'postgres')
			db_name: utils.default(cfg.value('postgres.db_name').string(), 'vpm')
		}
	}
}

pub fn generate(path string) ? {
	return error('not implemented')
}
