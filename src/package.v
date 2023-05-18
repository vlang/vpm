module main

import vweb
import entity
import lib.log

const basic_categories = [
	entity.Category{
		name: 'Command line tools'
	},
	entity.Category{
		name: 'Networking'
	},
	entity.Category{
		name: 'Game development'
	},
	entity.Category{
		name: 'Web programming'
	},
]

['/api/packages'; post]
pub fn (mut app App) api_create_package(name string, vcsUrl string, description string) vweb.Result {
	app.packages.create(name, vcsUrl, description, app.cur_user) or { return app.json(err.msg()) }

	return app.ok('ok')
}

['/api/packages/id/:package_id'; delete]
pub fn (mut app App) delete_package(package_id int) vweb.Result {
	if !app.is_logged_in() {
		app.set_status(401, 'Unauthorized')
		return app.json({
			'error': 'you must be logged in to delete a package'
		})
	}

	app.packages.delete(package_id, app.cur_user.id) or { return app.not_found() }

	return app.ok('ok')
}

['/api/packages/:name']
pub fn (mut app App) get_package_by_name(name string) vweb.Result {
	package := app.packages.get(name) or { return app.json('404') }

	return app.json(package)
}

// TODO: Delete jsmod after V install command is updated to use the new get_package_by_name and incr_downloads endpoints
['/jsmod/:name']
pub fn (mut app App) jsmod(name string) vweb.Result {
	log.info()
		.add('name', name)
		.msg('jsMOD')

	package := app.packages.get(name) or { return app.json('404') }
	return app.json(package)
}

['/api/packages/:name/incr_downloads'; post]
pub fn (mut app App) incr_downloads(name string) vweb.Result {
	app.packages.incr_downloads(name) or { return app.json('404') }

	return app.ok('ok')
}
