import os
import cli
import toml
import net.http

const (
	template_of_main_file =
'fn main() {
	println(\'Hello, world!\')
}
'
)

fn main() {
	mut vpm := cli.Command {
		name: 'vpm'
		description: 'VLang Package Manager'
		execute: fn (cmd cli.Command) ? {
			println('Hello from VPM!') // TODO: Create a list of commands in the near future
		}
		commands: [
			cli.Command {
				name: 'install'
				execute: fn (cmd cli.Command) ? {
					json_config := parse_toml_config()
					println(json_config)
				}
			}
			cli.Command {
				name: 'init'
				execute: fn (cmd cli.Command) ? {
					os.mkdir('src') ? {
						mut main_file := os.create('src/main.v') ?
						main_file.write_string(template_of_main_file) ?

						create_toml_file(os.base(os.getwd()))
					}
				}
			}
			cli.Command {
				name: 'new'
				execute: fn (cmd cli.Command) ? {
					project_name := os.args[3]
					project_path := $if windows {
						'$os.getwd()\\$project_name\\src'
					} $else {
						'$os.getwd()/$project_name/src'
					}
					
					os.mkdir_all(project_path) ? {
						mut main_file := os.create('$project_name/src/main.v') ?
						main_file.write_string(template_of_main_file) ?

						create_toml_file(project_name)
					}
				}
			}
		]
	}

	vpm.setup()
	vpm.parse(os.args)	
}

fn create_toml_file(project_name string) {
	init_toml_body :=
'[package]
name = "$project_name"
author = "Your Name <adress@gmail.com>"
description = ""
license = ""
version = "0.0.1"

[dependencies]

'

	mut config := os.create('$project_name/vpm.toml') or {
		mut config := os.create('vpm.toml') or {
			panic(err)
		}

		config.write_string(init_toml_body) or {
			panic(err)
		}

		config.close()
		
		return
	}

	config.write_string(init_toml_body) or {
		panic(err)
	}

	config.close()
}

fn parse_toml_config() string {
	config := toml.parse_file('vpm.toml') or {
		panic(err)
	} 
	
	println('>> List of packages:')
	for package_name, version in config.value('dependencies').as_map() {
		print ('\t$package_name - $version | ')

		http.download_file_with_progress('https://vpm.vlang.io/api/$package_name/$version')
	}
	println('')
}
