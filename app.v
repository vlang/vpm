module main

import vweb
import lib.log
import entity

pub fn (mut app App) index() vweb.Result {
	categories := []entity.Category{}
	app.set_cookie(
		name: 'vpm'
		value: '777'
	)
	println('cur user id:${app.cur_user.id}')
	your_packages := app.packages.find_by_user(app.cur_user.id)

	return $vweb.html()
}

fn (mut app App) new() vweb.Result {
	logged_in := app.cur_user.username != ''
	log.info().msg('new() loggedin: ${logged_in}')
	return $vweb.html()
}

['/packages/:name']
pub fn (mut app App) mod(name string) vweb.Result {
	println('mod name=${name}')
	pkg := app.packages.get(name) or {
		println(err)
		return app.redirect('/')
	}
	return $vweb.html()
}

['/'; post]
pub fn (mut app App) create_package(name string, description string, vcs string) vweb.Result {
	app.packages.create(name, description, vcs, app.cur_user.id) or {
		log.error()
			.add('error', err)
			.add('vcs', vcs)
			.add('name', name)
			.add('description', description)
			.add('user_id', app.cur_user.id)
			.msg('error creating package')
		return app.new()
	}
	return app.redirect('/')
}
