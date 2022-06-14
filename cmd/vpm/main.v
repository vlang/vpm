module main

import app
import app.config

const (
	config_file = './config.toml'
)

fn main() {
	cfg := config.parse_file(config_file) or {
		println(err)
		exit(1)
	}
	
	app.run(cfg) or {
		println(err)
		exit(1)
	}
}
