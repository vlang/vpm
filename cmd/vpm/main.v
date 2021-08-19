module main

import app

const (
	config_file = './config.json'
)

fn main() {
	app.run(config_file) ?
}
