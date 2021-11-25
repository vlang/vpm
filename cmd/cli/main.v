import os
import cli
import toml
import net.urllib
// import net.http

const (
	template_of_main_file = "module main

fn main() {
	println('Hello, world!')
}
"
)

fn module_template(project_name string) string {
	template := '[package]
name = "$project_name"
author = "Your Name <example@gmail.com>"
description = ""
license = ""
version = "0.1.0"

[dependencies]

'
	return template
}

fn main() {
	mut vpm := cli.Command{
		name: 'vpm'
		description: 'VLang Package Manager'
		execute: fn (cmd cli.Command) ? {
			println('Hello from VPM!') // TODO: Create a list of commands in the near future
		}
		commands: [
			cli.Command{
				name: 'install'
				execute: fn (cmd cli.Command) ? {
					_ := parse_toml_config(os.join_path(os.getwd(), 'vpm.toml')) ?
					// println(json_config)
				}
			},
			cli.Command{
				name: 'init'
				execute: fn (cmd cli.Command) ? {
					project_path := os.getwd()
					project_name := os.file_name(project_path)
					init_project(project_path, project_name) ?
				}
			},
			cli.Command{
				name: 'new'
				execute: fn (cmd cli.Command) ? {
					if cmd.args.len < 0 {
						cmd.execute_help()
						return
					}

					project_name := cmd.args.first()
					if _ := os.mkdir(project_name) {
						init_project(os.join_path('.', project_name), project_name) ?
					}
				}
			},
		]
	}

	vpm.setup()
	vpm.parse(os.args)
}

fn init_project(basepath string, name string) ? {
	os.write_file(os.join_path(basepath, 'vpm.toml'), module_template(name)) ?
	os.write_file(os.join_path(basepath, 'main.v'), template_of_main_file) ?
}

fn parse_toml_config(filepath string) ?[]string {
	config := toml.parse_file(filepath) ?

	val := config.value('dependencies')

	if val !is map[string]toml.Any {
		println('no dependencies')
		return []string{}
	}

	dependencies := val.as_map()
	mut parsed_dependencies := []string{cap: dependencies.len}

	println('>> List of packages:')
	for package_name, version in dependencies {
		version_string := version.string()
		print('\t$package_name - $version_string | ')
		parsed_dependencies << package_name + '@' + version_string

		escaped_package := urllib.path_escape(package_name)
		escaped_version := urllib.path_escape(version_string)

		println('Package source: `https://vpm.vlang.io/api/$escaped_package/${escaped_version}.zip`')
		// http.download_file('https://vpm.vlang.io/api/$escaped_package/$escaped_version.zip',
		// 	os.join_path('.', parsed_dependencies.last() + '.zip')) ?
	}

	return parsed_dependencies
}
