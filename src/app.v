module main

import vweb
import lib.log
import entity

pub fn (mut app App) before_request() {
	app.recently_updated_packages = app.packages.get_recently_updated_packages()
	app.nr_packages = app.packages.get_packages_count()
	app.new_packages = app.packages.get_new_packages()
	app.most_downloaded_packages = app.packages.get_most_downloaded_packages()
	app.auth()
}

pub fn (mut app App) index() vweb.Result {
	categories := []entity.Category{}
	app.set_cookie(
		name: 'vpm'
		value: '777'
	)

	log.info()
		.add('cur user id', app.cur_user.id)
		.msg('index()')

	your_packages := app.packages.find_by_user(app.cur_user.id)

	return $vweb.html()
}

pub fn (mut app App) is_logged_in() bool {
	log.info()
		.add('user id', app.cur_user.id)
		.add('username', app.cur_user.username)
		.msg('user is logged in')

	return app.cur_user.username != ''
}

pub fn (mut app App) format_nr_packages() string {
	if app.nr_packages == 1 {
		return '${app.nr_packages} package'
	}

	return '${app.nr_packages} packages'
}

fn (mut app App) new() vweb.Result {
	logged_in := app.cur_user.username != ''
	log.info().msg('new() loggedin: ${logged_in}')

	return $vweb.html()
}

['/packages/:name']
pub fn (mut app App) package(name string) vweb.Result {
	pkg := app.packages.get(name) or {
		log.error()
			.add('error', err.str())
			.msg('error getting package')

		return app.redirect('/')
	}

	return $vweb.html()
}

['/create_package'; post]
pub fn (mut app App) create_package(name string, url string, description string) vweb.Result {
	app.packages.create(name, url, description, app.cur_user) or {
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
