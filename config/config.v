module config

import os
import toml

pub struct Config {
pub mut:
	root_url string
	jwt      JWT
	gh       Github
	http     HTTP
	pg       Postgres
}

pub struct JWT {
pub mut:
	secret string
}

pub struct Github {
pub mut:
	client_id string
	secret    string
}

pub struct HTTP {
pub mut:
	root_url string
	port     int
}

pub struct Postgres {
pub mut:
	host     string
	port     int
	user     string
	password string
	db       string
}

pub fn parse_file(path string) ?Config {
	if !os.exists(path) {
		return error('config file does not exist')
	}

	data := os.read_file(path)?
	return parse(data)
}

pub fn parse(data string) ?Config {
	cfg := toml.parse_text(data) or { return error('failed to parse toml: $err') }

	return Config{
		root_url: cfg.value('root_url').default_to('http://localhost:8080').string()
		jwt: JWT{
			secret: cfg.value('jwt.secret').default_to('very_secure_secret').string()
		}
		gh: Github{
			client_id: cfg.value_opt('github.client_id')?.string()
			secret: cfg.value_opt('github.secret')?.string()
		}
		http: HTTP{
			port: cfg.value('http.port').default_to(8080).int()
		}
		pg: Postgres{
			host: cfg.value('postgres.host').default_to('localhost').string()
			port: cfg.value('postgres.port').default_to(5432).int()
			user: cfg.value('postgres.user').default_to('vpm').string()
			password: cfg.value('postgres.password').default_to('vpm').string()
			db: cfg.value('postgres.db').default_to('vpm').string()
		}
	}
}

pub fn generate(path string) ? {
	return error('not implemented')
}
