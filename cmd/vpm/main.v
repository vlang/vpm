module main

import app

const (
	config_file = './config.toml'
)

fn main() {
	app.run(config_file) ?
}
