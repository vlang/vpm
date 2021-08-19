module config

import os
import json

pub struct Config {
pub mut:
	sqlite SqliteConfig
	http   HTTPConfig
}

pub struct SqliteConfig {
pub mut:
	path string = ':memory:'
}

pub struct HTTPConfig {
pub mut:
	port int = 8080
}

pub fn new(path string) ?Config {
	if !os.exists(path) {
		return error('config file does not exist')
	}

	file := os.read_file(path)?
	return json.decode(Config, file)
}

pub fn generate(path string) ? {
	return error('not implemented')
}
