module main

import veb
import lib.log
import net.http

@['/api/packages'; post]
pub fn (app &App) api_create_package(mut ctx Context, name string, vcsUrl string, description string) veb.Result {
	app.packages().create(name, vcsUrl, description, ctx.cur_user) or { return ctx.json(err.msg()) }
	return ctx.ok('ok')
}

@['/api/packages/id/:package_id'; delete]
pub fn (app &App) delete_package(mut ctx Context, package_id int) veb.Result {
	if !ctx.is_logged_in() {
		ctx.res.set_status(.unauthorized)
		return ctx.json({
			'error': 'you must be logged in to delete a package'
		})
	}

	app.packages().delete(package_id, ctx.cur_user.id) or { return ctx.not_found() }

	return ctx.ok('ok')
}

@['/api/packages/:name']
pub fn (mut app App) get_package_by_name(mut ctx Context, name string) veb.Result {
	package := app.packages().get(name) or { return ctx.json('404') }

	return ctx.json(package)
}

@['/api/packages/:name/incr_downloads'; post]
pub fn (mut app App) incr_downloads(mut ctx Context, name string) veb.Result {
	app.packages().incr_downloads(name) or { return ctx.json('404') }

	return ctx.ok('ok')
}

// TODO: Delete jsmod and delete_package_deprecated some time after V is updated to use the new API endpoints

@['/jsmod/:name']
pub fn (mut app App) jsmod_deprecated(mut ctx Context, name string) veb.Result {
	log.info()
		.add('name', name)
		.msg('jsMOD')

	package := app.packages().get(name) or { return ctx.json('404') }
	return ctx.json(package)
}

@['/delete_package/:package_id'; post]
pub fn (mut app App) delete_package_deprecated(mut ctx Context, package_id int) veb.Result {
	return app.delete_package(mut ctx, package_id)
}
