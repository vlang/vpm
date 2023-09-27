module main

import vweb
import lib.log
import lib.storage
import markdown

['/new']
fn (mut app App) new() vweb.Result {
	logged_in := app.cur_user.username != ''
	log.info().msg('new() loggedin: ${logged_in}')

	return $vweb.html()
}

['/users/:name']
pub fn (mut app App) user(name string) vweb.Result {
	user := app.users().get_by_name(name) or {
		error := 'Not found such user'
		return app.html($tmpl('./templates/error.html'))
	}

	packages := app.packages().find_by_user(user.id)

	return $vweb.html()
}

['/packages/:name']
pub fn (mut app App) package(name string) vweb.Result {
	pkg := app.packages().get(name) or {
		println(err)
		return app.redirect('/')
	}

	categories := app.packages().get_package_categories(pkg.id) or { [] }

	// Getting README from repo or storage
	readme_path := '/packages_readme/${pkg.id}/README.html'
	data := app.storage.read(readme_path) or {
		if err != storage.err_not_found {
			println('failed to read readme from storage: ${err}')
			return app.redirect('/')
		}

		println('fetching readme from repo for `${pkg.name}`')

		// TODO: figure out when to update readme
		readme := app.packages().get_package_markdown(name) or {
			println('failed to get readme from repo: ${err}')
			return app.redirect('/')
		}

		rendered := markdown.to_html(readme).bytes()

		app.storage.save(readme_path, rendered) or {
			println('failed to save readme to storage: ${err}')
		}

		rendered
	}

	pkg_readme := data.bytestr()

	return app.html($tmpl('./templates/package.html'))
}

['/create_package'; post]
pub fn (mut app App) create_package(name string, url string, description string) vweb.Result {
	app.packages().create(name, url, description, app.cur_user) or {
		log.error()
			.add('error', err.str())
			.add('url', url)
			.add('name', name)
			.add('description', description)
			.add('user_id', app.cur_user.id)
			.msg('error creating package')

		app.error(err.msg())
		return app.new()
	}

	return app.redirect('/')
}

['/api/packages'; post]
pub fn (mut app App) api_create_package(name string, vcsUrl string, description string) vweb.Result {
	app.packages().create(name, vcsUrl, description, app.cur_user) or { return app.json(err.msg()) }

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

	app.packages().delete(package_id, app.cur_user.id) or { return app.not_found() }

	return app.ok('ok')
}

['/api/packages/:name']
pub fn (mut app App) get_package_by_name(name string) vweb.Result {
	package := app.packages().get(name) or { return app.json('404') }

	return app.json(package)
}

['/api/packages/:name/incr_downloads'; post]
pub fn (mut app App) incr_downloads(name string) vweb.Result {
	app.packages().incr_downloads(name) or { return app.json('404') }

	return app.ok('ok')
}

// TODO: Delete jsmod and delete_package_deprecated some time after V is updated to use the new API endpoints

['/jsmod/:name']
pub fn (mut app App) jsmod_deprecated(name string) vweb.Result {
	log.info()
		.add('name', name)
		.msg('jsMOD')

	package := app.packages().get(name) or { return app.json('404') }
	return app.json(package)
}

['/delete_package/:package_id'; post]
pub fn (mut app App) delete_package_deprecated(package_id int) vweb.Result {
	return app.delete_package(package_id)
}
