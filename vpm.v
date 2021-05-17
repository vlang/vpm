module main

import time
import os
import vweb
import sqlite
import json
import models
import vsqlite

const (
	// Port on which the application will run
	http_port = 8080
)

struct App {
	vweb.Context
mut:
	started_at u64
	packages models.PackageService
	users models.UserService
	logged_in  bool
	user       User
}

fn main() {
	vweb.run<App>(http_port)
}

// App initialization
pub fn (mut app App) init_once() {
	app.started_at = time.now().unix

	// Connect to database
	db := sqlite.connect('vpm.sqlite') or {
		println('failed to connect to db')
		panic(err)
	}
	app.packages = vsqlite.new_package_service(db) or {panic(err)}
	app.users = vsqlite.new_user_service(db) or {panic(err)}

	if os.getenv('VPM_SKIP_STATIC') !in ['1', 'true'] {
		app.handle_static('./static/', true)
	}
}

// Global middleware
pub fn (mut app App) init() {
	app.logged_in = app.logged_in()
	if app.logged_in {
		app.user = app.get_user_from_cookies() or {
			app.logged_in = false
			User{}
		}
	}
}

// ==API Endpoints==

// Old module retrive
['/jsmod/:name']
pub fn (mut app App) jsmod(name string) vweb.Result {
	pkg := app.get_package_by_name(name) or {
		eprintln('GET /jsmod/$name $err')
		return app.not_found()
	}
	
	return app.json(json.encode(pkg.get_old_package()))
}

[post]
['/api/user']
pub fn (mut app App) api_user_create() vweb.Result {
	mut usr := models.user_from_map(app.form) or {
		app.set_status(400, 'Please provide valid user')
		return app.server_error(1)
	}

	usr := app.users.create_user(usr) or {
		eprintln('POST /api/user $err')
		app.set_status(500, 'Error then creating user')
		return app.server_error(1)
	}
	
	return app.json(json.encode(usr))
}

['/api/user/:user']
pub fn (mut app App) api_user(user string) vweb.Result {
	usr := app.get_user(user) or {
		eprintln('GET /api/user/$user $err')
		return app.not_found()
	}

	return app.json(json.encode(usr))
}

[delete]
['/api/user/:user']
pub fn (mut app App) api_user_delete(user string) vweb.Result {
	usr := app.users.delete_user(usr.id) or {
		eprintln('DELETE /api/user/$user $err')
		return app.not_found()
	}

	return app.json(json.encode(usr))
}

['/api/package/:package']
pub fn (mut app App) api_package(package string) vweb.Result {
	pkg := app.get_package(package) or {
		eprintln('GET /api/package/$package $err')
		return app.not_found()
	}

	return app.json(json.encode(pkg))
}	

[delete]
['/api/package/:package']
pub fn (mut app App) api_package_delete(package string) vweb.Result {
	if !app.user.is_admin {
		eprintln('DELETE /api/package/$package Not authorized')
		app.set_status(401, "")
		return app.ok("")
	}

	pkg := app.delete_package(pkg.id) or {
		eprintln('DELETE /api/package/$package $err')
		return app.not_found()
	}

	return app.json(json.encode(pkg))
}

// ==Frontend Endpoints==

// Homepage
pub fn (mut app App) index() vweb.Result {
	nr_packages := 149
	new_packages := app.packages.get_packages_sorted_by_created_at(10, 0) or {}
	most_downloaded_packages := app.packages.get_packages_sorted_by_downloads(10, 0) or {}
	recently_updated_packages := app.packages.get_packages_sorted_by_last_updated(10, 0) or {}
	// TODO: most recent downloads
	most_recent_downloads_packages := app.packages.get_packages_sorted_by_last_updated(10, 0) or {}
	// TODO: tags
	popular_tags := app.packages.get_packages_sorted_by_last_updated(10, 0) or {}
	// TODO: categories
	popular_categories := app.packages.get_packages_sorted_by_last_updated(10, 0) or {}
	return $vweb.html()
}

// Create module
pub fn (mut app App) create() vweb.Result {
	return $vweb.html()
}

// Create module handler
[post]
['/create']
pub fn (mut app App) create_package() vweb.Result {
	if !app.logged_in {
		if 'repo_url' !in app.form {
			app.set_status(400, "Please provide 'repo_url'")
			app.error("'repo_url' is not provided")
			return app.ok("")
		}

		repo_url := app.form['repo_url']

		// TODO: get repo info from git
		package := Package{
			author_id: app.user.id
			name: 'test'
			version: '0.1.0'
			description: 'Test package'
			license: 'MIT'
			repo_url: repo_url
		}
		app.insert_package(package) // should return result row
		return app.json(json.encode(package))
	}
	app.error('Not logged in')
	return app.server_error(401)
}

// Browse modules
pub fn (mut app App) browse() vweb.Result {
	// packages := app.get_all_packages() or {
	// 	return app.server_error(500)
	// }
	browse_header := 'All packages'
	packages := app.get_some_random_package_info(20)
	return $vweb.html()
}

// Login endpoint
pub fn (mut app App) login() vweb.Result {
	return app.redirect(app.get_login_link())
}

// Logout endpoint
pub fn (mut app App) logout() vweb.Result {
	app.set_cookie(name: 'id', value: '')
	app.set_cookie(name: 'token', value: '')
	return app.redirect('/')
}

['/:username']
pub fn (mut app App) user(username string) vweb.Result {
	return $vweb.html()
}

['/:username/:package']
pub fn (mut app App) package(username string, package string) vweb.Result {
	current_package := PackageInfo{}
	return $vweb.html()
}
