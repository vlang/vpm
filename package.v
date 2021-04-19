module main

import models

fn (mut app App) get_package(query string) ?Package {
	mut not_found := false
	mut error := error('')

	mut pkg := app.packages.get_package(query.int()) or { // get package by id
		not_found = true
		error = err
		Package{}
	}
	if not_found == false {
		return usr
	}

	not_found = false

	pkg = app.packages.get_package_by_name(query) or {
		not_found = true
		error = err
		Package{}
	}
	if not_found == false {
		return pkg
	}

	return err
}