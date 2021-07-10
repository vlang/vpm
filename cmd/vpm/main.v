module main

import app

const (
	config_file = './main.toml'
)

fn main() {
	app.run(config_file) ?
}
