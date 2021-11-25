module main

import app

const (
	config_file = './config.toml'
)

fn main() {
	println('Starting...')
	app.run(config_file) ?
}
