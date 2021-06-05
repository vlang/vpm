module main

// import app
// import config

// fn main() {
// 	app.run(config.get())
// }

import vpm.app

const (
	config_file = "./main.toml"
)

fn main() {
	app.run(config_file) ?
}
