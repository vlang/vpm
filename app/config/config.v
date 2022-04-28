module config

import os
import toml

pub struct Config {
pub:
	root_url string
	gh   Github
	http HTTP
	pg   Postgres
}

pub struct Github {
pub mut:
	client_id string
	secret    string
}

pub struct HTTP {
pub mut:
	root_url string
	port int
}

pub struct Postgres {
pub mut:
	host     string 
	port     int  
	user     string
	password string 
	db_name  string
}

pub fn parse_file(path string) ?Config {
	if !os.exists(path) {
		return error('config file does not exist')
	}

	data := os.read_file(path) ?
	return parse(data)
}

pub fn parse(data string) ?Config {
	cfg := toml.parse_text(data) or {
		return error('failed to parse toml: $err')
	}

	return Config{
		root_url: cfg.value('http.root_url').default_to('http://localhost:8080').string()
		gh: Github{
			client_id: cfg.value('github.client_id').string()
			secret: cfg.value('github.secret').string()
		}
		http: HTTP{
			port: cfg.value('http.port').default_to(8080).int()
		}
		pg: Postgres{
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
